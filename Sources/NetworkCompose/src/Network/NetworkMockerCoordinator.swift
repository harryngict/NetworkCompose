//
//  NetworkMockerCoordinator.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

final class NetworkMockerCoordinator<SessionType: NetworkSession>: NetworkCoordinatorInterface {
    var reAuthService: ReAuthenticationService?

    private let observeQueue: DispatchQueueType
    private let mockHanlder: NetworkMockHandler

    init(baseURL _: URL,
         session _: SessionType = URLSession.shared,
         reAuthService: ReAuthenticationService?,
         executeQueue: DispatchQueueType,
         observeQueue: DispatchQueueType,
         mockerStrategy: MockerStrategy)
    {
        self.reAuthService = reAuthService
        self.observeQueue = observeQueue
        mockHanlder = NetworkMockHandler(mockerStrategy,
                                         executeQueue: executeQueue)
    }

    func request<RequestType>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        retryPolicy _: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        requestMockResponse(request, completion: completion)
    }

    func upload<RequestType>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        fromFile _: URL,
        retryPolicy _: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        requestMockResponse(request, completion: completion)
    }

    func download<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        retryPolicy _: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        requestMockResponse(request, completion: completion)
    }
}

extension NetworkMockerCoordinator {
    func requestMockResponse<RequestType>(
        _ request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        do {
            let result = try mockHanlder.getRequestResponse(request)
            observeQueue.async {
                completion(.success(result))
            }
        } catch {
            observeQueue.async {
                let networkError = NetworkError.error(nil, error.localizedDescription)
                completion(.failure(networkError))
            }
        }
    }
}
