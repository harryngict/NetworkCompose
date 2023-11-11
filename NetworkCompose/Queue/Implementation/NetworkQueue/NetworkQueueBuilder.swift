//
//  NetworkQueueBuilder.swift
//  NetworkCompose/Queue
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// A builder for constructing instances of `NetworkQueue`.
///
/// Example usage:
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let networkQueue = NetworkQueueBuilder(baseURL: baseURL)
///     .setReAuthService(yourReAuthService)
///     .setSecurityTrust(yourSecurityTrust)
///     .build()
/// ```
public class NetworkQueueBuilder<SessionType: NetworkSession>: NetworkComposerBase<SessionType> {
    public var reAuthService: ReAuthenticationService?

    /// Initializes a `NetworkQueueBuilder` with a base URL and a default session.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests. Defaults to `URLSession.shared`.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    public required init(baseURL: URL,
                         session: SessionType = URLSession.shared,
                         networkReachability: NetworkReachability = NetworkReachabilityImp.shared,
                         executeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.executeQueue,
                         observeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.observeQueue)
    {
        super.init(baseURL: baseURL,
                   session: session,
                   networkReachability: networkReachability,
                   executeQueue: executeQueue,
                   observeQueue: observeQueue)
    }

    /// Sets the re-authentication service.
    ///
    /// - Parameter reAuthService: The service responsible for re-authentication.
    /// - Returns: The builder instance for method chaining.
    public func setReAuthService(_ reAuthService: ReAuthenticationService?) -> Self {
        self.reAuthService = reAuthService
        return self
    }

    /// Builds and returns a `NetworkQueue` instance with the configured parameters.
    ///
    /// - Returns: A fully configured `NetworkQueue` instance.
    public func build() -> NetworkQueue<SessionType> {
        return NetworkQueue(
            baseURL: baseURL,
            session: session,
            reAuthService: reAuthService,
            networkReachability: networkReachability,
            executeQueue: executeQueue,
            observeQueue: observeQueue
        )
    }
}
