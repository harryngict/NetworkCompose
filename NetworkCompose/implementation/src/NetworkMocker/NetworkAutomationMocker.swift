//
//  NetworkAutomationMocker.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 25/11/23.
//

import Foundation
import NetworkCompose

// MARK: - NetworkAutomationMocker

final class NetworkAutomationMocker<SessionType: NetworkSession>: NetworkRouterInterface {
  // MARK: Lifecycle

  init(baseURL _: URL,
       session: SessionType = URLSession.shared,
       reAuthService: ReAuthenticationService?,
       executionQueue: DispatchQueueType,
       observationQueue: DispatchQueueType,
       loggerInterface: LoggerInterface?,
       dataType: AutomationMode.DataType)
  {
    self.session = session
    self.reAuthService = reAuthService
    self.observationQueue = observationQueue
    self.loggerInterface = loggerInterface
    mockHandler = NetworkMockHandler(
      dataType,
      loggerInterface: loggerInterface,
      executionQueue: executionQueue)
  }

  // MARK: Internal

  var reAuthService: ReAuthenticationService?

  var cookieStorage: CookieStorage { session.cookieStorage }

  func request<RequestType>(_ request: RequestType,
                            andHeaders _: [String: String] = [:],
                            retryPolicy _: RetryPolicy = .disabled,
                            completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) where RequestType: RequestInterface
  {
    loggerInterface?.log(.debug, request.debugDescription)
    requestMockResponse(request, completion: completion)
  }

  func upload<RequestType>(_ request: RequestType,
                           andHeaders _: [String: String] = [:],
                           fromFile _: URL,
                           retryPolicy _: RetryPolicy = .disabled,
                           completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) where RequestType: RequestInterface
  {
    loggerInterface?.log(.debug, request.debugDescription)
    requestMockResponse(request, completion: completion)
  }

  func download<RequestType>(_ request: RequestType,
                             andHeaders _: [String: String] = [:],
                             retryPolicy _: RetryPolicy = .disabled,
                             completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) where RequestType: RequestInterface
  {
    loggerInterface?.log(.debug, request.debugDescription)
    requestMockResponse(request, completion: completion)
  }

  func cancelRequest(
    _ request: some RequestInterface
  ) {
    loggerInterface?.log(.debug, request.debugDescription)
  }

  // MARK: Private

  private let observationQueue: DispatchQueueType
  private let mockHandler: NetworkMockHandler
  private let loggerInterface: LoggerInterface?
  private let session: SessionType
}

private extension NetworkAutomationMocker {
  func requestMockResponse<RequestType>(_ request: RequestType,
                                        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) where RequestType: RequestInterface
  {
    do {
      let result = try mockHandler.getRequestResponse(request)
      observationQueue.async {
        completion(.success(result))
      }
    } catch {
      observationQueue.async {
        let networkError = NetworkError.error(nil, error.localizedDescription)
        completion(.failure(networkError))
      }
    }
  }
}
