//
//  NetworkSessionExecutorImp.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 11/11/23.
//

import Foundation
import NetworkCompose

// MARK: - NetworkSessionExecutorImp

final class NetworkSessionExecutorImp<SessionType: NetworkSession>: NetworkSessionExecutor {
  // MARK: Lifecycle

  // MARK: - Initialization

  /// Initializes a new instance of `NetworkSessionExecutorImp`.
  ///
  /// - Parameters:
  ///   - baseURL: The base URL for network requests.
  ///   - session: The network session to use for requests.
  ///   - networkReachability: The network reachability object.
  ///   - executionQueue: The dispatch queue for executing network requests.
  ///   - observationQueue: The dispatch queue for observing and handling network events.
  ///   - storageService: The service for handling storage-related tasks.
  ///   - loggerInterface: The interface for logging network events.
  init(baseURL: URL,
       session: SessionType,
       networkReachability: NetworkReachabilityInterface,
       executionQueue: DispatchQueueType,
       observationQueue: DispatchQueueType,

       loggerInterface: LoggerInterface?)
  {
    self.baseURL = baseURL
    self.session = session
    self.networkReachability = networkReachability
    self.executionQueue = executionQueue
    self.observationQueue = observationQueue

    self.loggerInterface = loggerInterface
    self.networkReachability.startMonitoring(completion: { _ in })
  }

  // MARK: Public

  /// The network reachability object.
  public let networkReachability: NetworkReachabilityInterface

  // MARK: Internal

  func request<RequestType>(_ request: RequestType,
                            andHeaders headers: [String: String] = [:],
                            retryPolicy: RetryPolicy = .disabled,
                            completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) where RequestType: RequestInterface
  {
    loggerInterface?.log(.debug, request.debugDescription)

    performNetworkTask(
      request,
      headers: headers,
      retryPolicy: retryPolicy,
      completion: completion)
    { sessionRequest, networkTaskCompletion in
      self.session.beginRequest(sessionRequest, completion: networkTaskCompletion)
    }
  }

  func cancelRequest(
    _ request: some RequestInterface
  ) {
    loggerInterface?.log(.debug, request.debugDescription)
    let identifier = UniqueKey(request: request)
    if let task = activeTasks[identifier] {
      task.cancel()
      activeTasks.removeValue(forKey: identifier)
    }
  }

  // MARK: Private

  // MARK: - Properties

  /// The base URL for network requests.
  private let baseURL: URL

  /// The network session to use for requests.
  private let session: SessionType

  /// The dispatch queue for executing network requests.
  private let executionQueue: DispatchQueueType

  /// The dispatch queue for observing and handling network events.
  private let observationQueue: DispatchQueueType

  /// An optional logger interface for logging.
  private var loggerInterface: LoggerInterface?

  /// Dictionary to store active network tasks.
  private var activeTasks = DictionaryInThreadSafe<UniqueKey, NetworkTask>()
}

private extension NetworkSessionExecutorImp {
  func performNetworkTask<RequestType>(_ request: RequestType,
                                       headers: [String: String] = [:],
                                       retryPolicy: RetryPolicy,
                                       completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void,
                                       taskProvider: @escaping (SessionType.SessionRequest,
                                                                @escaping (Result<ResponseInterface, NetworkError>) -> Void) throws -> NetworkTask) where RequestType: RequestInterface
  {
    guard networkReachability.isInternetAvailable else {
      observationQueue.async {
        completion(.failure(NetworkError.lostInternetConnection))
      }
      return
    }

    var currentRetry = 0

    func performRequest() {
      do {
        let identifier = UniqueKey(request: request)
        let networkRequest = try buildNetworkRequest(for: request, andHeaders: headers)
        let task = try taskProvider(networkRequest) { [weak self] result in
          self?.handleResult(result, for: request) { result in
            switch result {
            case let .success(model):
              self?.observationQueue.async {
                completion(.success(model))
              }
            case let .failure(error):
              currentRetry += 1
              self?.retryIfNeeded(
                currentRetry: currentRetry,
                retryPolicy: retryPolicy,
                error: error,
                performRequest: performRequest,
                completion: completion)
            }
            self?.activeTasks.removeValue(forKey: identifier)
          }
        }
        activeTasks[identifier] = task
      } catch {
        observationQueue.async {
          completion(.failure(NetworkError.invalidSession))
        }
      }
    }

    executionQueue.async {
      performRequest()
    }
  }

  func retryIfNeeded<SuccessType>(currentRetry: Int,
                                  retryPolicy: RetryPolicy,
                                  error: NetworkError,
                                  performRequest: @escaping () -> Void,
                                  completion: @escaping (Result<SuccessType, NetworkError>) -> Void) where SuccessType: Decodable
  {
    let configuration = retryPolicy.retryConfiguration(forAttempt: currentRetry)
    if configuration.shouldRetry {
      loggerInterface?.log(.debug, "NetworkSessionExecutor retry count: \(currentRetry) delay: \(configuration.delay)")
      executionQueue.asyncAfter(deadline: .now() + configuration.delay) {
        performRequest()
      }
    } else {
      observationQueue.async {
        completion(.failure(error))
      }
    }
  }

  func buildNetworkRequest(for request: some RequestInterface,
                           andHeaders headers: [String: String]) throws
    -> SessionType.SessionRequest
  {
    try session.build(request, withBaseURL: baseURL, andHeaders: headers)
  }

  func handleResult<RequestType>(_ result: Result<ResponseInterface, NetworkError>,
                                 for request: RequestType,
                                 completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) where RequestType: RequestInterface
  {
    switch result {
    case let .success(response):
      do {
        let decodedResponse = try handleSuccessResponse(response, for: request)
        completion(.success(decodedResponse))
      } catch {
        if let error = error as? NetworkError {
          completion(.failure(error))
        } else if let decodingError = error as? DecodingError {
          completion(.failure(NetworkError.decodingFailed(
            modeType: String(describing: RequestType.SuccessType.self),
            context: decodingError.localizedDescription)))
        } else {
          completion(.failure(NetworkError.error(nil, error.localizedDescription)))
        }
      }
    case let .failure(error):
      completion(.failure(error))
    }
  }

  func handleSuccessResponse<RequestType>(_ response: ResponseInterface,
                                          for request: RequestType) throws
    -> RequestType.SuccessType where RequestType: RequestInterface
  {
    guard (200 ... 299).contains(response.statusCode) else {
      throw NetworkError.error(response.statusCode, nil)
    }
    let model = try request.responseDecoder.decode(
      RequestType.SuccessType.self,
      from: response.data)

    return model
  }
}
