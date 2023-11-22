//
//  NetworkKitQueueFacade.swift
//  NetworkSwift/Queue
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A facade for interacting with the network, providing a high-level interface for network requests and handling re-authentication.
///
/// Example usage:
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let facade = try? NetworkKitQueueFacade(baseURL: baseURL)
/// facade?.request(yourNetworkRequest) { result in
///     switch result {
///     case .success(let data):
///         // Handle successful response
///     case .failure(let error):
///         // Handle error
///     }
/// }
/// ```
public final class NetworkKitQueueFacade<SessionType: NetworkSession> {
    /// The underlying network kit responsible for handling network requests.
    private let networkKitQueue: NetworkKitQueue

    /// Initializes the `NetworkKitQueueFacade` with the specified configuration.
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
        networkKitQueue = NetworkKitQueueImp(baseURL: baseURL,
                                             session: session,
                                             reAuthService: reAuthService,
                                             serialOperationQueue: serialOperationQueue)
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
    public init(baseURL: URL,
                securityTrust: NetworkSecurityTrust,
                reAuthService: ReAuthenticationService? = nil,
                serialOperationQueue: OperationQueueManager = OperationQueueManagerImp(maxConcurrentOperationCount: 1)) throws
    {
        networkKitQueue = try NetworkKitQueueBuilder(baseURL: baseURL)
            .setSecurityTrust(securityTrust)
            .setReAuthService(reAuthService)
            .setSerialOperationQueue(serialOperationQueue)
            .build()
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
    public init(baseURL: URL,
                sessionDelegate: URLSessionDelegate,
                reAuthService: ReAuthenticationService? = nil,
                serialOperationQueue: OperationQueueManager = OperationQueueManagerImp(maxConcurrentOperationCount: 1)) throws
    {
        networkKitQueue = try NetworkKitQueueBuilder(baseURL: baseURL)
            .setSessionDelegate(sessionDelegate)
            .setReAuthService(reAuthService)
            .setSerialOperationQueue(serialOperationQueue)
            .build()
    }

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
        networkKitQueue.request(request, andHeaders: headers,
                                retryPolicy: retryPolicy,
                                completion: completion)
    }
}
