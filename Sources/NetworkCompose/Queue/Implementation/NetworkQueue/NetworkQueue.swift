//
//  NetworkQueue.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

final class NetworkQueue<SessionType: NetworkSession>: NetworkQueueInterface {
    private let network: NetworkInterface
    private let operationQueue: OperationQueueManager
    public var reAuthService: ReAuthenticationService?

    /// Initializes the `NetworkQueue` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    ///   - reAuthService: The service responsible for re-authentication.
    ///   - operationQueue: The operation queue manager for serializing network operations. Default is `serialOperationQueue`.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    init(
        baseURL: URL,
        session: SessionType,
        reAuthService: ReAuthenticationService?,
        operationQueue: OperationQueueManager,
        networkReachability: NetworkReachability,
        executeQueue: NetworkDispatchQueue,
        observeQueue: NetworkDispatchQueue
    ) {
        self.reAuthService = reAuthService
        self.operationQueue = operationQueue
        network = Network(baseURL: baseURL,
                          session: session,
                          networkReachability: networkReachability,
                          executeQueue: executeQueue,
                          observeQueue: observeQueue)
    }

    func request<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        if request.requiresReAuthentication {
            let operation = createReAuthenticationOperation(request, andHeaders: headers,
                                                            retryPolicy: retryPolicy,
                                                            completion: completion)
            operationQueue.enqueue(operation)
        } else {
            sendRequest(request, andHeaders: headers,
                        allowReAuth: false,
                        retryPolicy: retryPolicy,
                        completion: completion)
        }
    }

    /// Creates an operation to handle re-authentication and execute the specified request.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called when the request is complete.
    /// - Returns: The created operation.
    private func createReAuthenticationOperation<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) -> CustomOperation {
        let asyncOperation = ClosureCustomOperation { operation in
            operation.state = .executing
            self.sendRequest(request, andHeaders: headers,
                             allowReAuth: request.requiresReAuthentication,
                             retryPolicy: retryPolicy)
            { result in
                switch result {
                case let .success(model): completion(.success(model))
                case let .failure(error): completion(.failure(error))
                }
                operation.state = .finished
            }
        }

        return asyncOperation
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
                            self.sendRequest(request, andHeaders: newHeaders, allowReAuth: false,
                                             retryPolicy: retryPolicy,
                                             completion: completion)
                        case let .failure(error):
                            self.cancelAllOperations()
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    private func cancelAllOperations() {
        guard let operations = operationQueue.operationQueue.operations as? [ClosureCustomOperation] else {
            return
        }
        for operation in operations {
            operation.validOperation = false
        }
    }
}
