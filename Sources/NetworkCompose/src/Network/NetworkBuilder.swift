//
//  NetworkBuilder.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// A builder class responsible for configuring and creating network-related functionality.
public class NetworkBuilder<SessionType: NetworkSession>: NetworkBuilderSettings<SessionType> {
    /// The service responsible for re-authentication.
    private var reAuthService: ReAuthenticationService?

    /// Initializes a new instance of `NetworkBuilder`.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to be used. Defaults to `URLSession.shared`.
    public required init(baseURL: URL,
                         session: SessionType = URLSession.shared)
    {
        super.init(baseURL: baseURL, session: session)
    }

    /// Sets the re-authentication service for the builder.
    ///
    /// - Parameter reAuthService: The service responsible for re-authentication.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func reAuthenService(_ reAuthService: ReAuthenticationService?) -> Self {
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
    @discardableResult
    override public func applyDefaultConfiguration() -> Self {
        reAuthService = nil
        _ = super.applyDefaultConfiguration()
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
                                              executionQueue: executionQueue)
        try? provider.clearMockDataInDisk()
        return self
    }

    /// Builds and returns an instance conforming to `NetworkRouterInterface` based on the configured strategies.
    ///
    /// This method creates either a `NetworkNavigator` or a `NetworkMocker` based on the specified strategies.
    ///
    /// - Returns: An instance conforming to `NetworkRouterInterface`.
    public func build() -> NetworkRouterInterface {
        if case let .enabled(mockDataType) = automationMode {
            return NetworkMocker(
                baseURL: baseURL,
                session: session,
                reAuthService: reAuthService,
                executionQueue: executionQueue,
                observationQueue: observationQueue,
                loggerInterface: createLogger(),
                mockDataType: mockDataType
            )
        } else {
            var storageService: StorageService?
            if case .enabled = recordResponseMode {
                storageService = StorageServiceProvider(loggerInterface: createLogger(),
                                                        executionQueue: executionQueue)
            }
            if let session = try? createNetworkSession() { self.session = session }
            return NetworkRouter(
                baseURL: baseURL,
                session: session,
                reAuthService: reAuthService,
                networkReachability: networkReachability,
                executionQueue: executionQueue,
                observationQueue: observationQueue,
                storageService: storageService,
                loggerInterface: createLogger()
            )
        }
    }
}
