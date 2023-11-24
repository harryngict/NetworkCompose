//
//  NetworkBuilderBase.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// A base class for building network configurations.
///
public class NetworkBuilderBase<SessionType: NetworkSession> {
    /// The base URL for network requests.
    var baseURL: URL

    /// The network session to use for requests.
    var session: SessionType

    /// The security trust policy for SSL pinning.
    var sslPinningPolicy: NetworkSSLPinningPolicy = .ignore

    /// The metrics collector object for collecting network metrics.
    var metricInterceptor: NetworkMetricInterceptor?

    /// The network reachability object for monitoring internet connection status.
    var networkReachability: NetworkReachability

    /// The dispatch queue for executing network requests.
    var executeQueue: NetworkDispatchQueue

    /// The dispatch queue for observing and handling network events.
    var observeQueue: NetworkDispatchQueue

    /// Then environment represents the current network environment for the application.
    var strategy: NetworkStrategy

    /// Initializes a `NetworkComposeBase` with a base URL and a default session.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    ///   - strategy: The network strategy to be applied.
    public required init(baseURL: URL,
                         session: SessionType,
                         networkReachability: NetworkReachability = NetworkReachabilityImp.shared,
                         executeQueue: NetworkDispatchQueue,
                         observeQueue: NetworkDispatchQueue,
                         strategy: NetworkStrategy)
    {
        self.baseURL = baseURL
        self.session = session
        self.networkReachability = networkReachability
        self.executeQueue = executeQueue
        self.observeQueue = observeQueue
        self.strategy = strategy
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

    /// Creates and returns a network session with the configured parameters.
    ///
    /// This method initializes a network session with the provided metrics collector and security trust,
    /// and returns an instance conforming to the specified `SessionType`.
    ///
    /// - Throws: A `NetworkError.invalidSession` if the session cannot be created.
    ///
    /// - Returns: A fully configured network session conforming to the specified `SessionType`.
    ///
    /// - Parameter sslPinningPolicy: A `NetworkSSLPinningPolicy` for SSL pinning.
    /// - Parameter metricInterceptor: An optional `NetworkMetricInterceptor` for collecting network metrics.
    ///
    /// - Important: If a `securityTrust` is provided, SSL pinning will be enabled.
    ///
    /// - Note: This method is used internally by the `NetworkComposeBase` to create the network session.
    private func createNetworkSession() throws -> SessionType {
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
