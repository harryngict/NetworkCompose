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
    var sslPinningPolicy: NetworkSSLPinningPolicy?
    var metricInterceptor: NetworkMetricInterceptor?
    var networkReachability: NetworkReachability = NetworkReachabilityImp.shared
    var executeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.executeQueue
    var observeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.observeQueue
    var strategy: NetworkStrategy?

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
    public func setSSLPinningPolicy(_ sslPinningPolicy: NetworkSSLPinningPolicy) throws -> Self {
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
    public func setMetricInterceptor(_ metricInterceptor: NetworkMetricInterceptor) throws -> Self {
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

    /// Sets the network strategy for handling network events.
    ///
    /// - Parameter strategy: The network strategy to be set.
    /// - Returns: The builder instance for method chaining.
    public func setNetworkStrategy(_ strategy: NetworkStrategy) -> Self {
        self.strategy = strategy
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
        strategy = nil
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
    func createNetworkSession() throws -> SessionType {
        do {
            let delegate = NetworkSessionProxyDelegate(sslPinningPolicy: sslPinningPolicy,
                                                       metricInterceptor: metricInterceptor)

            guard let session = URLSession(configuration: NetworkSessionConfiguration.default,
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
