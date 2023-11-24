//
//  NetworkBuilder.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// A builder for constructing instances of `NetworkImp`.
///
/// This builder provides a convenient way to create and configure a `NetworkImp` instance for making network requests.
///
/// ## Example Usage
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let network = try? NetworkBuilder(baseURL: baseURL)
///     .setSSLPinningPolicy(yourSSLPinningPolicy)
///     .build()
/// ```
public class NetworkBuilder<SessionType: NetworkSession>: NetworkBuilderBase<SessionType> {
    /// Initializes a `NetworkBuilder` with a base URL and a default session.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
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

    /// Builds and returns a `NetworkImp` instance with the configured parameters.
    ///
    /// - Returns: A fully configured `NetworkImp` instance.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public func build() -> NetworkImp<SessionType> {
        return NetworkImp(
            baseURL: baseURL,
            session: session,
            networkReachability: networkReachability,
            executeQueue: executeQueue,
            observeQueue: observeQueue
        )
    }
}