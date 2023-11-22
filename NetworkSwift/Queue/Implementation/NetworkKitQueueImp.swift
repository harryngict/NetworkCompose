//
//  NetworkKitQueueImp.swift
//  NetworkSwift/Queue
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

/// A class implementing the `NetworkKitQueue` protocol that manages the execution of network requests.
///
/// Example usage:
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let networkKitQueue = NetworkKitQueueImp(baseURL: baseURL)
/// ```

public final class NetworkKitQueueImp<SessionType: NetworkSession>: NetworkKitQueue {
    /// The underlying network kit responsible for handling network requests.
    private let networkKit: NetworkKit

    /// The operation queue manager used to serialize network operations.
    private let serialOperationQueue: OperationQueueManager

    /// The service responsible for re-authentication if required.
    public var reAuthService: ReAuthenticationService?

    // MARK: Initialization

    /// Initializes the `NetworkKitQueueImp` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    ///   - reAuthService: The service responsible for re-authentication.
    ///   - serialOperationQueue: The operation queue manager for serializing network operations.
    public init(
        baseURL: URL,
        session: SessionType = URLSession.shared,
        reAuthService: ReAuthenticationService? = nil,
        serialOperationQueue: OperationQueueManager = OperationQueueManagerImp(maxConcurrentOperationCount: 1)
    ) {
        self.reAuthService = reAuthService
        self.serialOperationQueue = serialOperationQueue
        networkKit = NetworkKitImp(baseURL: baseURL, session: session)
    }

    /// Convenience initializer for SSL pinning using a custom security trust.
    ///
    /// Use this initializer to create a `NetworkKitQueueImp` instance with SSL pinning configured using a custom security trust.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - reAuthService: The service responsible for re-authentication.
    ///   - securityTrust: The security trust object for SSL pinning.
    ///   - configuration: The session configuration for the URL session. The default is `NetworkSessionConfiguration.default`.
    ///   - delegateQueue: The operation queue on which the delegate will receive URLSessionDelegate callbacks.
    ///                    The default value is the main operation queue.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public convenience init(baseURL: URL,
                            reAuthService: ReAuthenticationService? = nil,
                            securityTrust: NetworkSecurityTrust,
                            configuration: URLSessionConfiguration = NetworkSessionConfiguration.default,
                            delegateQueue: OperationQueue? = OperationQueue.main) throws
    {
        let delegate = NetworkSessionTaskDelegate(securityTrust: securityTrust)
        guard let session = URLSession(configuration: configuration,
                                       delegate: delegate,
                                       delegateQueue: delegateQueue) as? SessionType
        else {
            throw NetworkError.invalidSession
        }
        self.init(baseURL: baseURL, session: session, reAuthService: reAuthService)
    }

    /// Convenience initializer for a custom session delegate.
    ///
    /// Use this initializer to create a `NetworkKitQueueImp` instance with a custom session delegate.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - reAuthService: The service responsible for re-authentication.
    ///   - sessionDelegate: The custom session delegate to handle various session events.
    ///   - configuration: The session configuration for the URL session. The default is `NetworkSessionConfiguration.default`.
    ///   - delegateQueue: The operation queue on which the delegate will receive URLSessionDelegate callbacks.
    ///                    The default value is the main operation queue.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public convenience init(baseURL: URL,
                            reAuthService: ReAuthenticationService? = nil,
                            sessionDelegate: URLSessionDelegate,
                            configuration: URLSessionConfiguration = NetworkSessionConfiguration.default,
                            delegateQueue: OperationQueue? = OperationQueue.main) throws
    {
        guard let session = URLSession(configuration: configuration,
                                       delegate: sessionDelegate,
                                       delegateQueue: delegateQueue) as? SessionType
        else {
            throw NetworkError.invalidSession
        }
        self.init(baseURL: baseURL, session: session, reAuthService: reAuthService)
    }

    // MARK: Public Methods

    /// Initiates a network request and handles re-authentication if necessary.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - completion: The completion handler to be called when the request is complete.
    public func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        if request.requiresReAuthentication {
            let operation = createReAuthenticationOperation(request, andHeaders: headers, completion: completion)
            serialOperationQueue.enqueue(operation)
        } else {
            sendRequest(request, andHeaders: headers, allowReAuth: false, completion: completion)
        }
    }

    // MARK: Create ReAuthenticationOperation

    /// Creates an operation to handle re-authentication and execute the specified request.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - completion: The completion handler to be called when the request is complete.
    /// - Returns: The created operation.
    private func createReAuthenticationOperation<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) -> CustomOperation {
        let asyncOperation = ClosureCustomOperation { operation in
            operation.state = .executing
            self.sendRequest(request, andHeaders: headers, allowReAuth: request.requiresReAuthentication) { result in
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
    ///   - completion: The completion handler to be called when the request is complete.
    private func sendRequest<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        allowReAuth: Bool,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        debugPrint(request.debugDescription)
        networkKit.request(request, andHeaders: headers) { result in
            switch result {
            case let .success(model):
                completion(.success(model))
            case let .failure(error):
                if error.errorCode == 401, allowReAuth, let reAuthService = self.reAuthService {
                    reAuthService.reAuthen { reAuthResult in
                        switch reAuthResult {
                        case let .success(newHeaders):
                            self.sendRequest(request, andHeaders: newHeaders, allowReAuth: false, completion: completion)
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

    /// Cancels all operations in the serial operation queue.
    private func cancelAllOperations() {
        guard let operations = serialOperationQueue.operationQueue.operations as? [ClosureCustomOperation] else {
            return
        }
        for operation in operations {
            operation.validOperation = false
        }
    }
}
