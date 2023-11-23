//
//  NetworkQueueImp.swift
//  NetworkSwift/Queue
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

/// A class implementing the `NetworkQueue` protocol that manages the execution of network requests.
///
/// Example usage:
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let networkKitQueue = NetworkQueueImp(baseURL: baseURL)
/// ```
public final class NetworkQueueImp<SessionType: NetworkSession>: NetworkQueue {
    /// The underlying network kit responsible for handling network requests.
    private let networkKit: NetworkKitImp<SessionType>

    /// The operation queue manager used to  network operations.
    private let operationQueue: OperationQueueManager

    /// The service responsible for re-authentication if required.
    public var reAuthService: ReAuthenticationService?

    // MARK: Initialization

    /// Initializes the `NetworkQueueImp` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    ///   - reAuthService: The service responsible for re-authentication.
    ///   - operationQueue: The operation queue manager for serializing network operations. Default is `serialOperationQueue`.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    public init(
        baseURL: URL,
        session: SessionType = URLSession.shared,
        reAuthService: ReAuthenticationService? = nil,
        operationQueue: OperationQueueManager = DefaultOperationQueueManager.serialOperationQueue,
        networkReachability: NetworkReachability = NetworkReachabilityImp.shared,
        executeQueue: NetworkDispatchQueue,
        observeQueue: NetworkDispatchQueue
    ) {
        self.reAuthService = reAuthService
        self.operationQueue = operationQueue
        networkKit = NetworkKitImp(baseURL: baseURL,
                                   session: session,
                                   networkReachability: networkReachability,
                                   executeQueue: executeQueue,
                                   observeQueue: observeQueue)
    }

    // MARK: Public Methods

    /// Initiates a network request and handles re-authentication if necessary.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called when the request is complete.
    public func request<RequestType: NetworkRequest>(
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

    // MARK: Create ReAuthenticationOperation

    /// Creates an operation to handle re-authentication and execute the specified request.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called when the request is complete.
    /// - Returns: The created operation.
    private func createReAuthenticationOperation<RequestType: NetworkRequest>(
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

    // MARK: NetworkService send request

    /// Sends the specified network request and handles re-authentication if necessary.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - allowReAuth: A flag indicating whether re-authentication is allowed.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called when the request is complete.
    private func sendRequest<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        allowReAuth: Bool,
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        networkKit.request(request, andHeaders: headers, retryPolicy: retryPolicy) { result in
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

    /// Cancels all operations in the operation queue.
    private func cancelAllOperations() {
        guard let operations = operationQueue.operationQueue.operations as? [ClosureCustomOperation] else {
            return
        }
        for operation in operations {
            operation.validOperation = false
        }
    }
}
