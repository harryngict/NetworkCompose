//
//  NetworkSessionExecutor.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

/// This class encapsulates the logic for making network requests using a specified network session.
/// It provides methods for handling various types of network tasks, such as regular requests,
/// file uploads, and file downloads. The class supports retry policies, network reachability checks,
/// and error handling during network operations.
final class NetworkSessionExecutor<SessionType: NetworkSession>: NetworkSessionExecutorInteface {
    // MARK: - Properties

    /// The base URL for network requests.
    private let baseURL: URL

    /// The network session to use for requests.
    private let session: SessionType

    /// The network reachability object.
    public let networkReachability: NetworkReachabilityInterface

    /// The dispatch queue for executing network requests.
    private let executionQueue: DispatchQueueType

    /// The dispatch queue for observing and handling network events.
    private let observationQueue: DispatchQueueType

    /// An optional storage service for handling persistent data.
    private var storageService: StorageService?

    /// An optional logger interface for logging.
    private var loggerInterface: LoggerInterface?

    /// Dictionary to store active network tasks.
    private var activeTasks = DictionaryInThreadSafe<UniqueKey, NetworkTask>()

    // MARK: - Initialization

    /// Initializes the `NetworkSessionExecutor` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    ///   - networkReachability: The network reachability object.
    ///   - executionQueue: The dispatch queue for executing network requests.
    ///   - observationQueue: The dispatch queue for observing and handling network events.
    ///   - storageService: An optional storage service for handling persistent data.
    ///   - loggerInterface: An optional logger interface for logging.
    init(baseURL: URL,
         session: SessionType,
         networkReachability: NetworkReachabilityInterface,
         executionQueue: DispatchQueueType,
         observationQueue: DispatchQueueType,
         storageService: StorageService?,
         loggerInterface: LoggerInterface?)
    {
        self.baseURL = baseURL
        self.session = session
        self.networkReachability = networkReachability
        self.executionQueue = executionQueue
        self.observationQueue = observationQueue
        self.storageService = storageService
        self.loggerInterface = loggerInterface
        self.networkReachability.startMonitoring(completion: { _ in })
    }

    func request<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        performNetworkTask(request, headers: headers, retryPolicy: retryPolicy, completion: completion) {
            self.session.beginRequest($0, completion: $1)
        }
    }

    func upload<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        fromFile fileURL: URL,
        retryPolicy: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        performNetworkTask(request, headers: headers, retryPolicy: retryPolicy, completion: completion) {
            self.session.beginUploadTask($0, fromFile: fileURL, completion: $1)
        }
    }

    func download<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        performNetworkTask(request, headers: headers, retryPolicy: retryPolicy, completion: completion) {
            self.session.beginDownloadTask($0, completion: $1)
        }
    }

    func cancelRequest<RequestType>(
        _ request: RequestType
    ) where RequestType: RequestInterface {
        loggerInterface?.log(.debug, request.debugDescription)
        let identifier = UniqueKey(request: request)
        if let task = activeTasks[identifier] {
            task.cancel()
            activeTasks.removeValue(forKey: identifier)
        }
    }
}

private extension NetworkSessionExecutor {
    private func performNetworkTask<RequestType>(
        _ request: RequestType,
        headers: [String: String] = [:],
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void,
        taskProvider: @escaping (SessionType.SessionRequest, @escaping (Result<ResponseInterface, NetworkError>) -> Void) throws -> NetworkTask
    ) where RequestType: RequestInterface {
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
                            self?.retryIfNeeded(currentRetry: currentRetry,
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

    private func buildNetworkRequest<RequestType>(
        for request: RequestType,
        andHeaders headers: [String: String]
    ) throws -> SessionType.SessionRequest where RequestType: RequestInterface {
        return try session.build(request, withBaseURL: baseURL, andHeaders: headers)
    }

    private func handleResult<RequestType>(
        _ result: Result<ResponseInterface, NetworkError>,
        for request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        switch result {
        case let .success(response):
            do {
                let decodedResponse = try handleSuccessResponse(response, for: request)
                completion(.success(decodedResponse))
            } catch {
                if let error = error as? NetworkError {
                    completion(.failure(error))
                } else if let decodingError = error as? DecodingError {
                    completion(.failure(NetworkError.decodingFailed(modeType: String(describing: RequestType.SuccessType.self),
                                                                    context: decodingError.localizedDescription)))
                } else {
                    completion(.failure(NetworkError.error(nil, error.localizedDescription)))
                }
            }
        case let .failure(error):
            completion(.failure(error))
        }
    }

    private func handleSuccessResponse<RequestType>(
        _ response: ResponseInterface,
        for request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: RequestInterface {
        guard (200 ... 299).contains(response.statusCode) else {
            throw NetworkError.error(response.statusCode, nil)
        }
        let model = try request.responseDecoder.decode(RequestType.SuccessType.self, from: response.data)

        /// Store object for automation testing.
        if let storageService = storageService {
            try storageService.storeResponse(request,
                                             data: response.data,
                                             model: model)
        }
        return model
    }

    private func retryIfNeeded<SuccessType>(
        currentRetry: Int,
        retryPolicy: RetryPolicy,
        error: NetworkError,
        performRequest: @escaping () -> Void,
        completion: @escaping (Result<SuccessType, NetworkError>) -> Void
    ) where SuccessType: Decodable {
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
}