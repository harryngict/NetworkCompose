//
//  NetworkBuilder.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public class NetworkBuilder<SessionType: NetworkSession>: NetworkCommonSettings<SessionType> {
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

    /// Clears mock data in the disk storage.
    ///
    /// This method is used to remove any mock data stored in the disk storage. It creates a `StorageServiceProvider`
    /// with the provided logger and executes the operation asynchronously on the specified queue.
    ///
    /// - Returns: An instance of the same type to support method chaining.
    @discardableResult
    public func clearMockDataInDisk() -> Self {
        let provider = StorageServiceProvider(loggerInterface: createLogger(),
                                              executeQueue: executeQueue)
        try? provider.clearMockDataInDisk()
        return self
    }

    /// Builds and returns an instance conforming to `NetworkCoordinatorInterface` based on the configured strategies.
    ///
    /// This method creates either a `NetworkCoordinator` or a `NetworkMocker` based on the specified strategies.
    ///
    /// - Returns: An instance conforming to `NetworkCoordinatorInterface`.
    public func build() -> NetworkCoordinatorInterface {
        guard case let .enabled(mockerDataType) = mockerStrategy else {
            var storageService: StorageService?

            if case .enabled = storageStrategy {
                storageService = StorageServiceProvider(loggerInterface: createLogger(),
                                                        executeQueue: executeQueue)
            }
            if let session = try? createNetworkSession() {
                self.session = session
            }

            return NetworkCoordinator(
                baseURL: baseURL,
                session: session,
                reAuthService: reAuthService,
                operationQueue: operationQueue,
                networkReachability: networkReachability,
                executeQueue: executeQueue,
                observeQueue: observeQueue,
                storageService: storageService,
                loggerInterface: createLogger()
            )
        }

        return NetworkMocker(
            baseURL: baseURL,
            session: session,
            reAuthService: reAuthService,
            executeQueue: executeQueue,
            observeQueue: observeQueue,
            loggerInterface: createLogger(),
            mockerDataType: mockerDataType
        )
    }
}
