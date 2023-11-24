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
public class NetworkBuilder<SessionType: NetworkSession>: NetworkBuilderBase<SessionType> {
    /// Initializes a `NetworkCompose` with a base URL and a default session.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests. Default is `URLSession.shared`.
    public required init(baseURL: URL,
                         session: SessionType = URLSession.shared)
    {
        super.init(baseURL: baseURL,
                   session: session)
    }

    /// Builds and returns a `NetworkInterface` instance with the configured parameters.
    ///
    /// - Returns: A fully configured `NetworkInterface` instance.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public func build() -> NetworkInterface {
        guard let strategy = strategy, case let .mocker(provider) = strategy else {
            return Network(
                baseURL: baseURL,
                session: session,
                networkReachability: networkReachability,
                executeQueue: executeQueue,
                observeQueue: observeQueue
            )
        }
        return NetworkDecorator(
            baseURL: baseURL,
            session: session,
            executeQueue: executeQueue,
            observeQueue: observeQueue,
            expectations: provider.networkExpectations
        )
    }
}
