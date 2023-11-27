//
//  NetworkBuilder.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public class NetworkBuilder<SessionType: NetworkSession>: NetworkSettings<SessionType> {
    private var reAuthService: ReAuthenticationService?
    private var operationQueue: OperationQueueManagerInterface = DefaultOperationQueueManager.serialOperationQueue

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
    @discardableResult
    public func setReAuthService(_ reAuthService: ReAuthenticationService?) -> Self {
        self.reAuthService = reAuthService
        return self
    }

    /// Sets the operation-queue service for the builder.
    ///
    /// - Parameter operationQueue: The queue run re-authentication operation
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func setOperationQueue(_ operationQueue: OperationQueueManagerInterface) -> Self {
        self.operationQueue = operationQueue
        return self
    }

    /// Resets the configuration of the network builder and its related properties to their default state.
    ///
    /// This method clears any custom re-authentication service, operation queue, SSL pinning policy,
    /// metric interceptor, network strategy, and sets default values for execution and observation queues,
    /// and network reachability.
    ///
    /// - Returns: The modified instance of the network builder with the default configuration.
    @discardableResult
    override public func setDefaultConfiguration() -> Self {
        reAuthService = nil
        operationQueue = DefaultOperationQueueManager.serialOperationQueue
        _ = super.setDefaultConfiguration()
        return self
    }

    public func build() -> NetworkCoordinatorInterface {
        guard let mockerStrategy = mockerStrategy else {
            var storageService: StorageService?
            if let storageStrategy { storageService = StorageServiceProvider(storageStrategy) }
            return NetworkCoordinator(
                baseURL: baseURL,
                session: session,
                reAuthService: reAuthService,
                operationQueue: operationQueue,
                networkReachability: networkReachability,
                executeQueue: executeQueue,
                observeQueue: observeQueue,
                storageService: storageService
            )
        }

        return NetworkMocker(
            baseURL: baseURL,
            session: session,
            reAuthService: reAuthService,
            executeQueue: executeQueue,
            observeQueue: observeQueue,
            mockerStrategy: mockerStrategy
        )
    }
}
