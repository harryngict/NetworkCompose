//
//  NetworkMocker.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

final class NetworkMocker<SessionType: NetworkSession>: NetworkProxyInterface {
    var reAuthService: ReAuthenticationService?

    private let observeQueue: NetworkDispatchQueue
    private lazy var automationHandler: NetworkAutomationHandler = .init()

    init(baseURL _: URL,
         session _: SessionType = URLSession.shared,
         reAuthService: ReAuthenticationService?,
         executeQueue _: NetworkDispatchQueue,
         observeQueue: NetworkDispatchQueue,
         expectations: [NetworkExpectation])
    {
        self.reAuthService = reAuthService
        self.observeQueue = observeQueue
        automationHandler.addExpectations(expectations)
    }

    func request<RequestType>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        retryPolicy _: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        requestMockResponse(request, completion: completion)
    }

    func upload<RequestType>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        fromFile _: URL,
        retryPolicy _: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        requestMockResponse(request, completion: completion)
    }

    func download<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        retryPolicy _: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        requestMockResponse(request, completion: completion)
    }
}

extension NetworkMocker {
    func requestMockResponse<RequestType>(
        _ request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        do {
            let result = try automationHandler.getRequestResponse(request)
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
