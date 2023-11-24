//
//  NetworkBuilder.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// A builder for constructing instances of `Network`.
///
/// This builder provides a convenient way to create and configure a `NetworkInterface` instance for making network requests.
///
/// ## Example Usage
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let network = try? NetworkBuilder(baseURL: baseURL)
///     .setSSLPinningPolicy(yourSSLPinningPolicy)
///     .build()
/// ```
public class NetworkBuilder<SessionType: NetworkSession>: NetworkBuilderBase<SessionType> {
    /// Initializes a `NetworkCompose` with a base URL and a default session.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests. Default is `URLSession.shared`.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executeQueue: The dispatch queue for executing network requests. Default is `DefaultNetworkDispatchQueue.executeQueue`.
    ///   - observeQueue: The dispatch queue for observing and handling network events. Default is `DefaultNetworkDispatchQueue.observeQueue`.
    ///   - strategy: The network strategy to be applied. Default is `.server`.
    public required init(baseURL: URL,
                         session: SessionType = URLSession.shared,
                         networkReachability: NetworkReachability = NetworkReachabilityImp.shared,
                         executeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.executeQueue,
                         observeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.observeQueue,
                         strategy: NetworkStrategy = .server)
    {
        super.init(baseURL: baseURL,
                   session: session,
                   networkReachability: networkReachability,
                   executeQueue: executeQueue,
                   observeQueue: observeQueue,
                   strategy: strategy)
    }

    /// Builds and returns a `NetworkInterface` instance with the configured parameters.
    ///
    /// - Returns: A fully configured `NetworkInterface` instance.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public func build() -> NetworkInterface {
        switch strategy {
        case let .mocker(provider):
            return NetworkDecorator(
                baseURL: baseURL,
                session: session,
                executeQueue: executeQueue,
                observeQueue: observeQueue,
                expectations: provider.networkExpectations
            )

        case .server:
            return Network(
                baseURL: baseURL,
                session: session,
                networkReachability: networkReachability,
                executeQueue: executeQueue,
                observeQueue: observeQueue
            )
        }
    }
}
