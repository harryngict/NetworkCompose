//
//  NetworkQueueBuilder.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public class NetworkQueueBuilder<SessionType: NetworkSession>: NetworkBuilderBase<SessionType> {
    /// The re-authentication service associated with the builder.
    private var reAuthService: ReAuthenticationService?

    /// The operation queue manager used to  network operations.
    private var operationQueue: OperationQueueManager = DefaultOperationQueueManager.serialOperationQueue

    /// Initializes a `NetworkQueueBuilder` with a base URL and a default session.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests. Defaults to `URLSession.shared`.
    public required init(baseURL: URL,
                         session: SessionType = URLSession.shared)
    {
        super.init(baseURL: baseURL,
                   session: session)
    }

    /// Sets the re-authentication service for the builder.
    ///
    /// - Parameter reAuthService: The service responsible for re-authentication.
    /// - Returns: The builder instance for method chaining.
    public func setReAuthService(_ reAuthService: ReAuthenticationService?) -> Self {
        self.reAuthService = reAuthService
        return self
    }

    /// Resets the configuration of the network builder and its related properties to their default state.
    ///
    /// This method clears any custom re-authentication service, operation queue, SSL pinning policy,
    /// metric interceptor, network strategy, and sets default values for execution and observation queues,
    /// and network reachability.
    ///
    /// - Returns: The modified instance of the network builder with the default configuration.
    override public func setDefaultConfiguration() -> Self {
        reAuthService = nil
        operationQueue = DefaultOperationQueueManager.serialOperationQueue
        _ = super.setDefaultConfiguration()
        return self
    }

    /// Builds and returns a `NetworkQueueInterface` instance with the configured parameters.
    ///
    /// - Returns: A fully configured `NetworkQueueInterface` instance.
    public func build() -> NetworkQueueInterface {
        guard let strategy = strategy, case let .mocker(provider) = strategy else {
            return NetworkQueue(
                baseURL: baseURL,
                session: session,
                reAuthService: reAuthService,
                operationQueue: operationQueue,
                networkReachability: networkReachability,
                executeQueue: executeQueue,
                observeQueue: observeQueue
            )
        }
        return NetworkQueueDecorator(
            baseURL: baseURL,
            session: session,
            reAuthService: reAuthService,
            executeQueue: executeQueue,
            observeQueue: observeQueue,
            expectations: provider.networkExpectations
        )
    }
}
