//
//  NetworkMocker.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

final class NetworkMocker<SessionType: NetworkSession>: NetworkRouterInterface {
    var reAuthService: ReAuthenticationService?

    private let observationQueue: DispatchQueueType
    private let mockHandler: NetworkMockHandler
    private let loggerInterface: LoggerInterface?

    init(baseURL _: URL,
         session _: SessionType = URLSession.shared,
         reAuthService: ReAuthenticationService?,
         executionQueue: DispatchQueueType,
         observationQueue: DispatchQueueType,
         loggerInterface: LoggerInterface?,
         mockDataType: AutomationMode.DataType)
    {
        self.reAuthService = reAuthService
        self.observationQueue = observationQueue
        self.loggerInterface = loggerInterface
        mockHandler = NetworkMockHandler(mockDataType,
                                         loggerInterface: loggerInterface,
                                         executionQueue: executionQueue)
    }

    func request<RequestType>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        retryPolicy _: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        loggerInterface?.log(.debug, request.debugDescription)
        requestMockResponse(request, completion: completion)
    }

    func upload<RequestType>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        fromFile _: URL,
        retryPolicy _: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        loggerInterface?.log(.debug, request.debugDescription)
        requestMockResponse(request, completion: completion)
    }

    func download<RequestType>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        retryPolicy _: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        loggerInterface?.log(.debug, request.debugDescription)
        requestMockResponse(request, completion: completion)
    }
}

private extension NetworkMocker {
    func requestMockResponse<RequestType>(
        _ request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
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
