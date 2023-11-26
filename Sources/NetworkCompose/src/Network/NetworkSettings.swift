//
//  NetworkSettings.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public class NetworkSettings<SessionType: NetworkSession> {
    var baseURL: URL
    var session: SessionType
    var sslPinningPolicy: SSLPinningPolicy?
    var metricInterceptor: MetricInterceptor?
    var networkReachability: NetworkReachability = NetworkReachabilityImp.shared
    var executeQueue: DispatchQueueType = DefaultNetworkDispatchQueue.executeQueue
    var observeQueue: DispatchQueueType = DefaultNetworkDispatchQueue.observeQueue
    /// The strategy for mocking network events.
    var mockerStrategy: MockerStrategy?
    /// The strategy for handling storable network events.
    var storageStrategy: StorageStrategy?
    public required init(baseURL: URL,
                         session: SessionType)
    {
        self.baseURL = baseURL
        self.session = session
    }

    /// Sets the security trust for SSL pinning.
    ///
    /// - Parameter sslPinningPolicy: The security trust object for SSL pinning.
    /// - Returns: The builder instance for method chaining.
    ///
    /// - Throws: A `NetworkError` if the session cannot be created.
    public func setSSLPinningPolicy(_ sslPinningPolicy: SSLPinningPolicy) throws -> Self {
        self.sslPinningPolicy = sslPinningPolicy
        session = try createNetworkSession()
        return self
    }

    /// Sets the metrics collector for network metrics.
    ///
    /// - Parameter metricInterceptor: The metrics collector object for collecting network metrics.
    /// - Returns: The builder instance for method chaining.
    ///
    /// - Throws: A `NetworkError` if the session cannot be created.
    public func setMetricInterceptor(_ metricInterceptor: MetricInterceptor) throws -> Self {
        self.metricInterceptor = metricInterceptor
        session = try createNetworkSession()
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
    public func setExecuteQueue(_ executeQueue: DispatchQueueType) -> Self {
        self.executeQueue = executeQueue
        return self
    }

    /// Sets the custom dispatch queue for observing and handling network events.
    ///
    /// - Parameter observeQueue: The custom dispatch queue for observing and handling network events.
    /// - Returns: The builder instance for method chaining.
    public func setObserveQueue(_ observeQueue: DispatchQueueType) -> Self {
        self.observeQueue = observeQueue
        return self
    }

    /// Sets the mocker strategy for the object.
    ///
    /// - Parameter strategy: The mocker strategy to be set.
    /// - Returns: The modified object with the updated mocker strategy.
    public func setMockerStrategy(_ strategy: MockerStrategy) -> Self {
        mockerStrategy = strategy
        return self
    }

    /// Sets the Storage strategy for handling network events.
    ///
    /// - Parameter strategy: The Storable strategy to be set.
    /// - Returns: The builder instance for method chaining.
    public func setStorageStrategy(_ strategy: StorageStrategy) -> Self {
        storageStrategy = strategy
        return self
    }

    /// Resets the configuration of the network builder to its default state.
    ///
    /// This method clears any custom SSL pinning policy, metric interceptor, network strategy,
    /// and sets default values for execution and observation queues, and network reachability.
    ///
    /// - Returns: The modified instance of the network builder with the default configuration.
    public func setDefaultConfiguration() -> Self {
        sslPinningPolicy = nil
        metricInterceptor = nil
        mockerStrategy = nil
        storageStrategy = nil
        executeQueue = DefaultNetworkDispatchQueue.executeQueue
        observeQueue = DefaultNetworkDispatchQueue.observeQueue
        networkReachability = NetworkReachabilityImp.shared
        if let session = try? createNetworkSession() {
            self.session = session
        }
        return self
    }
}

private extension NetworkSettings {
    /// Creates a network session based on the current SSL pinning policy and metric interceptor.
    ///
    /// - Returns: A network session instance.
    /// - Throws: A `NetworkError` if the session cannot be created.
    func createNetworkSession() throws -> SessionType {
        do {
            let delegate = SessionProxyDelegate(sslPinningPolicy: sslPinningPolicy,
                                                metricInterceptor: metricInterceptor)

            guard let session = URLSession(configuration: SessionConfiguration.default,
                                           delegate: delegate,
                                           delegateQueue: nil) as? SessionType
            else {
                throw NetworkError.invalidSession
            }

            return session
        } catch {
            throw NetworkError.invalidSession
        }
    }
}
