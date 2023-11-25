//
//  NetworkQueueDecorator.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

final class NetworkQueueDecorator<SessionType: NetworkSession>: NetworkQueueInterface {
    var reAuthService: ReAuthenticationService?
    private let network: NetworkDecorator<SessionType>

    /// Initializes the `NetworkDecorator` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests. Default is `URLSession.shared`.
    ///   - reAuthService: The reauthentication service to use. Default is `nil`.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    ///   - expectations: The expectations for mocking network responses.
    init(baseURL: URL,
         session: SessionType = URLSession.shared,
         reAuthService: ReAuthenticationService? = nil,
         executeQueue: NetworkDispatchQueue,
         observeQueue: NetworkDispatchQueue,
         expectations: [NetworkExpectation])
    {
        self.reAuthService = reAuthService
        network = NetworkDecorator(baseURL: baseURL,
                                   session: session,
                                   executeQueue: executeQueue,
                                   observeQueue: observeQueue,
                                   expectations: expectations)
    }

    func request<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        sendRequest(request, andHeaders: headers,
                    allowReAuth: request.requiresReAuthentication,
                    retryPolicy: retryPolicy,
                    completion: completion)
    }

    /// Sends the specified network request and handles re-authentication if necessary.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - allowReAuth: A flag indicating whether re-authentication is allowed.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called when the request is complete.
    private func sendRequest<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        allowReAuth: Bool,
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        network.request(request, andHeaders: headers, retryPolicy: retryPolicy) { result in
            switch result {
            case let .success(model):
                completion(.success(model))
            case let .failure(error):
                if error.errorCode == 401, allowReAuth, let reAuthService = self.reAuthService {
                    reAuthService.reAuthen { reAuthResult in
                        switch reAuthResult {
                        case let .success(newHeaders):
                            self.sendRequest(request,
                                             andHeaders: newHeaders,
                                             allowReAuth: false,
                                             retryPolicy: retryPolicy,
                                             completion: completion)
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
}
