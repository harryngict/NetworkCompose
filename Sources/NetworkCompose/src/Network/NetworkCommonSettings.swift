//
//  NetworkCommonSettings.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// Configuration settings for network operations using a specified network session type.
public class NetworkCommonSettings<SessionType: NetworkSession> {
    /// The base URL for the network requests.
    var baseURL: URL

    /// The session used for network communication conforming to the specified session type.
    var session: SessionType

    /// The SSL pinning policy to enhance security in network communication.
    var sslPinningPolicy: SSLPinningPolicy?

    /// Interceptor for capturing and measuring network metrics.
    var metricInterceptor: MetricInterceptor?

    /// Interface for monitoring network reachability.
    var networkReachability: NetworkReachabilityInterface

    /// The queue on which network operations are executed.
    var executeQueue: DispatchQueueType

    /// The queue on which network events are observed.
    var observeQueue: DispatchQueueType

    /// Provider for session configurations, allowing customization of network sessions.
    var sessionConfigurationProvider: SessionConfigurationProvider

    /// The strategy for mocking network events, useful for testing or simulating network behavior.
    var mockerStrategy: MockerStrategy?

    /// The strategy for handling storable network events, such as caching or persistent storage.
    var storageStrategy: StorageStrategy?

    /// The strategy for logging network events and activities.
    var loggingStrategy: LoggingStrategy

    public required init(baseURL: URL,
                         session: SessionType)
    {
        self.baseURL = baseURL
        self.session = session
        sslPinningPolicy = nil
        metricInterceptor = nil
        mockerStrategy = nil
        storageStrategy = nil
        executeQueue = DefaultNetworkDispatchQueue.executeQueue
        observeQueue = DefaultNetworkDispatchQueue.observeQueue
        networkReachability = NetworkReachability.shared
        sessionConfigurationProvider = DefaultSessionConfigurationProvider.normal
        loggingStrategy = .disabled
    }

    /// Sets the security trust for SSL pinning.
    ///
    /// - Parameter sslPinningPolicy: The security trust object for SSL pinning.
    /// - Returns: The builder instance for method chaining.
    ///
    /// - Throws: A `NetworkError` if the session cannot be created.
    @discardableResult
    public func setSSLPinningPolicy(_ sslPinningPolicy: SSLPinningPolicy) -> Self {
        self.sslPinningPolicy = sslPinningPolicy
        if let session = try? createNetworkSession() { self.session = session }
        return self
    }

    /// Sets the metrics collector for network metrics.
    ///
    /// - Parameter metricInterceptor: The metrics collector object for collecting network metrics.
    /// - Returns: The builder instance for method chaining.
    ///
    /// - Throws: A `NetworkError` if the session cannot be created.
    @discardableResult
    public func setMetricInterceptor(_ metricInterceptor: MetricInterceptor) -> Self {
        self.metricInterceptor = metricInterceptor
        if let session = try? createNetworkSession() { self.session = session }
        return self
    }

    /// Sets the custom network reachability object.
    ///
    /// - Parameter reachability: The custom network reachability object.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func setNetworkReachability(_ reachability: NetworkReachabilityInterface) -> Self {
        networkReachability = reachability
        return self
    }

    /// Sets the custom dispatch queue for executing network requests.
    ///
    /// - Parameter executeQueue: The custom dispatch queue for executing network requests.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func setExecuteQueue(_ executeQueue: DispatchQueueType) -> Self {
        self.executeQueue = executeQueue
        return self
    }

    /// Sets the custom dispatch queue for observing and handling network events.
    ///
    /// - Parameter observeQueue: The custom dispatch queue for observing and handling network events.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func setObserveQueue(_ observeQueue: DispatchQueueType) -> Self {
        self.observeQueue = observeQueue
        return self
    }

    /// Sets the mocker strategy for the object.
    ///
    /// - Parameter strategy: The mocker strategy to be set.
    /// - Returns: The modified object with the updated mocker strategy.
    @discardableResult
    public func setMockerStrategy(_ strategy: MockerStrategy) -> Self {
        mockerStrategy = strategy
        return self
    }

    /// Sets the Storage strategy for handling network events.
    ///
    /// - Parameter strategy: The Storable strategy to be set.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func setStorageStrategy(_ strategy: StorageStrategy) -> Self {
        storageStrategy = strategy
        return self
    }

    /// Sets the session configuration provider for the network.
    ///
    /// Use this method to provide a custom `SessionConfigurationProvider` to configure the network session.
    ///
    /// - Parameter provider: The session configuration provider.
    /// - Returns: An instance of the network with the updated session configuration provider.
    @discardableResult
    public func setSessionConfigurationProvider(_ provider: SessionConfigurationProvider) -> Self {
        sessionConfigurationProvider = provider
        if let session = try? createNetworkSession() { self.session = session }
        return self
    }

    /// Sets the logging strategy for the logger.
    ///
    /// - Parameter strategy: The logging strategy to set.
    /// - Returns: The logger instance with the updated logging strategy.
    @discardableResult
    public func setLoggingStrategy(_ strategy: LoggingStrategy) -> Self {
        loggingStrategy = strategy
        if let session = try? createNetworkSession() { self.session = session }
        return self
    }

    /// Resets the configuration of the network builder to its default state.
    ///
    /// This method clears any custom SSL pinning policy, metric interceptor, network strategy,
    /// and sets default values for execution and observation queues, and network reachability.
    ///
    /// - Returns: The modified instance of the network builder with the default configuration.
    @discardableResult
    public func setDefaultConfiguration() -> Self {
        sslPinningPolicy = nil
        metricInterceptor = nil
        mockerStrategy = nil
        storageStrategy = nil
        executeQueue = DefaultNetworkDispatchQueue.executeQueue
        observeQueue = DefaultNetworkDispatchQueue.observeQueue
        networkReachability = NetworkReachability.shared
        sessionConfigurationProvider = DefaultSessionConfigurationProvider.normal
        loggingStrategy = .disabled
        if let session = try? createNetworkSession() { self.session = session }
        return self
    }

    /// Creates a logger instance based on the specified logging strategy.
    ///
    /// - Parameter strategy: The logging strategy to determine the type of logger to create.
    /// - Returns: A logger instance conforming to `LoggerInterface` or `nil` if logging is disabled.
    func createLogger(from strategy: LoggingStrategy) -> LoggerInterface? {
        switch strategy {
        case .disabled:
            return nil
        case .enabled:
            return DefaultLogger.shared
        case let .custom(logger):
            return logger
        }
    }
}

private extension NetworkCommonSettings {
    /// Creates a network session based on the specified configurations.
    ///
    /// - Note: If SSL pinning policy, metric interceptor, logging strategy, or session configuration provider changes,
    ///   call this function to create a new session with the updated configurations.
    ///
    /// - Throws: A `NetworkError` if an invalid session is encountered during the creation process.
    /// - Returns: A session conforming to `SessionType`.
    func createNetworkSession() throws -> SessionType {
        let delegate = SessionProxyDelegate(sslPinningPolicy: sslPinningPolicy,
                                            metricInterceptor: metricInterceptor,
                                            loggerInterface: createLogger(from: loggingStrategy))

        guard let session = URLSession(configuration: sessionConfigurationProvider.sessionConfig,
                                       delegate: delegate,
                                       delegateQueue: nil) as? SessionType
        else {
            throw NetworkError.invalidSession
        }
        return session
    }
}
