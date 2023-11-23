//
//  NetworkKitQueueBuilder.swift
//  NetworkSwift/Queue
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

/// A builder for constructing instances of `NetworkKitQueueImp`.
///
/// Example usage:
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let networkKitQueue = NetworkKitQueueBuilder(baseURL: baseURL)
///     .setReAuthService(yourReAuthService)
///     .setSecurityTrust(yourSecurityTrust)
///     .build()
/// ```
public final class NetworkKitQueueBuilder<SessionType: NetworkSession> {
    /// The base URL for network requests.
    private let baseURL: URL

    /// The network session to use for requests.
    private var session: SessionType

    /// The service responsible for re-authentication if required.
    private var reAuthService: ReAuthenticationService?

    /// The network reachability object for monitoring internet connection status.
    private var networkReachability: NetworkReachability

    /// The dispatch queue for executing network requests.
    private var executeQueue: NetworkDispatchQueue

    /// The dispatch queue for observing and handling network events.
    private var observeQueue: NetworkDispatchQueue

    /// Initializes a `NetworkKitQueueBuilder` with a base URL and a default session.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests. Defaults to `URLSession.shared`.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    public init(baseURL: URL,
                session: SessionType = URLSession.shared,
                networkReachability: NetworkReachability = NetworkReachabilityImp.shared,
                executeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.executeQueue,
                observeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.observeQueue)
    {
        self.baseURL = baseURL
        self.session = session
        self.networkReachability = networkReachability
        self.executeQueue = executeQueue
        self.observeQueue = observeQueue
    }

    /// Sets the re-authentication service.
    ///
    /// - Parameter reAuthService: The service responsible for re-authentication.
    /// - Returns: The builder instance for method chaining.
    public func setReAuthService(_ reAuthService: ReAuthenticationService?) -> Self {
        self.reAuthService = reAuthService
        return self
    }

    /// Sets the custom network reachability object.
    ///
    /// - Parameter reachability: The custom network reachability object.
    /// - Returns: The builder instance for method chaining.
    public func setNetworkReachability(_ reachability: NetworkReachability) -> Self {
        networkReachability = reachability
        return self
    }

    /// Sets the custom dispatch queue for executing network requests.
    ///
    /// - Parameter executeQueue: The custom dispatch queue for executing network requests.
    /// - Returns: The builder instance for method chaining.
    public func setExecuteQueue(_ executeQueue: NetworkDispatchQueue) -> Self {
        self.executeQueue = executeQueue
        return self
    }

    /// Sets the custom dispatch queue for observing and handling network events.
    ///
    /// - Parameter observeQueue: The custom dispatch queue for observing and handling network events.
    /// - Returns: The builder instance for method chaining.
    public func setObserveQueue(_ observeQueue: NetworkDispatchQueue) -> Self {
        self.observeQueue = observeQueue
        return self
    }

    /// Builds and returns a `NetworkKitQueueImp` instance with the configured parameters.
    ///
    /// - Returns: A fully configured `NetworkKitQueueImp` instance.
    public func build() -> NetworkKitQueueImp<SessionType> {
        return NetworkKitQueueImp(
            baseURL: baseURL,
            session: session,
            reAuthService: reAuthService,
            networkReachability: networkReachability,
            executeQueue: executeQueue,
            observeQueue: observeQueue
        )
    }

    /// Sets the security trust for SSL pinning.
    ///
    /// - Parameter securityTrust: The security trust object for SSL pinning.
    /// - Throws: A `NetworkError` if the session cannot be created.
    /// - Returns: The builder instance for method chaining.
    public func setSecurityTrust(_ securityTrust: NetworkSecurityTrust) throws -> Self {
        do {
            let delegate = NetworkSessionTaskDelegate(securityTrust: securityTrust)
            guard let session = URLSession(
                configuration: NetworkSessionConfiguration.default,
                delegate: delegate,
                delegateQueue: nil /// `OperationQueue.main` Will throw message `This method should not be called on the main thread as it may lead to UI unresponsiveness.`
            ) as? SessionType else {
                throw NetworkError.invalidSession
            }
            self.session = session
        } catch {
            throw NetworkError.invalidSession
        }
        return self
    }
}
