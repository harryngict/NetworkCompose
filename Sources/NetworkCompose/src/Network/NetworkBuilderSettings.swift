//
//  NetworkBuilderSettings.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// A base class for configuring common settings related to network communication.
///
/// This class provides a set of methods to customize various aspects of network communication, such as SSL pinning, metric reporting,
/// network reachability, execution and observation queues, automation modes for testing, recording responses, session configuration,
/// logging, and default configurations.
///
/// To use this class, create an instance and chain the desired configuration methods, then use the resulting configured instance
/// to build and obtain a network session.
public class NetworkBuilderSettings<SessionType: NetworkSession> {
    /// The base URL for the network requests.
    var baseURL: URL

    /// The session used for network communication conforming to the specified session type.
    var session: SessionType

    /// The SSL pinning policy to enhance security in network communication.
    var sslPinningPolicy: SSLPinningPolicy

    /// The strategy for reporting metrics related to network tasks.
    var reportMetricStrategy: ReportMetricStrategy

    /// Interface for monitoring network reachability.
    var networkReachability: NetworkReachabilityInterface

    /// The queue on which network operations are executed.
    var executionQueue: DispatchQueueType

    /// The queue on which network events are observed.
    var observationQueue: DispatchQueueType

    /// Provider for session configurations, allowing customization of network sessions.
    var sessionConfigurationProvider: SessionConfigurationProvider

    /// The strategy for mocking network events, useful for testing or simulating network behavior.
    var automationMode: AutomationMode

    /// The mode for recording responses during network operations.
    var recordResponseMode: RecordResponseMode

    /// The strategy for logging network events and activities.
    var logStrategy: LogStrategy

    /// Initializes a new instance of `NetworkCommonSettings`.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to be used.
    public required init(baseURL: URL,
                         session: SessionType)
    {
        self.baseURL = baseURL
        self.session = session
        sslPinningPolicy = .disabled
        reportMetricStrategy = .disabled
        automationMode = .disabled
        recordResponseMode = .disabled
        logStrategy = .disabled
        executionQueue = DefaultDispatchQueue.executionQueue
        observationQueue = DefaultDispatchQueue.observationQueue
        networkReachability = NetworkReachability.shared
        sessionConfigurationProvider = DefaultSessionConfigurationProvider.ephemeral
    }

    /// Sets the security trust for SSL pinning.
    ///
    /// - Parameter sslPinningPolicy: The security trust object for SSL pinning.
    /// - Returns: The builder instance for method chaining.
    ///
    /// - Throws: A `NetworkError` if the session cannot be created.
    @discardableResult
    public func sslPinningPolicy(_ sslPinningPolicy: SSLPinningPolicy) -> Self {
        self.sslPinningPolicy = sslPinningPolicy
        return self
    }

    /// Sets the strategy for reporting metrics related to network tasks.
    ///
    /// Use this method to configure the strategy for reporting metrics associated with network tasks.
    /// The provided `strategy` parameter defines how metrics should be reported.
    ///
    /// - Parameter strategy: The strategy for reporting metrics related to network tasks.
    /// - Returns: An instance of the same type to support method chaining.
    @discardableResult
    public func reportMetric(_ strategy: ReportMetricStrategy) -> Self {
        reportMetricStrategy = strategy
        return self
    }

    /// Sets the custom network reachability object.
    ///
    /// - Parameter reachability: The custom network reachability object.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func networkReachability(_ reachability: NetworkReachabilityInterface) -> Self {
        networkReachability = reachability
        return self
    }

    /// Sets the custom dispatch queue for executing network requests.
    ///
    /// - Parameter queue: The custom dispatch queue for executing network requests.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func execute(on queue: DispatchQueueType) -> Self {
        executionQueue = queue
        return self
    }

    /// Sets the custom dispatch queue for observing and handling network events.
    ///
    /// - Parameter queue: The custom dispatch queue for observing and handling network events.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func observe(on queue: DispatchQueueType) -> Self {
        observationQueue = queue
        return self
    }

    /// Configures the automation mode for mocking in tests.
    ///
    /// - Parameter strategy: The mocking strategy to be applied for automation tests.
    /// - Returns: The modified instance allowing method chaining.
    ///
    /// Use this method to set the mocking strategy specifically tailored for automation tests. The provided `strategy` parameter defines how responses are mocked during automated testing scenarios.
    ///
    /// - Note: This method supports method chaining, enabling the convenient configuration of the mocking strategy within a single line.
    /// - SeeAlso: `AutomationMode` enum for available strategies tailored for automation testing.
    @discardableResult
    public func automationMode(_ strategy: AutomationMode) -> Self {
        automationMode = strategy
        return self
    }

    /// Sets the storage strategy for handling network events and recording responses for automation testing.
    ///
    /// - Parameter mode: The record response mode to be set.
    /// - Returns: The builder instance for method chaining.
    ///
    /// Use this method to configure the storage strategy for handling network events and record responses for automation testing. The provided `mode` parameter determines how responses are recorded and later utilized in automated testing scenarios.
    ///
    /// - Note: This method supports method chaining, allowing you to conveniently set the storage strategy and perform additional configurations in a single line.
    /// - SeeAlso: `RecordResponseMode` for available modes and customization options.
    @discardableResult
    public func recordResponseForTesting(_ mode: RecordResponseMode) -> Self {
        recordResponseMode = mode
        return self
    }

    /// Sets the session configuration provider for the network.
    ///
    /// Use this method to provide a custom `SessionConfigurationProvider` to configure the network session.
    ///
    /// - Parameter provider: The session configuration provider.
    /// - Returns: An instance of the network with the updated session configuration provider.
    @discardableResult
    public func sessionConfigurationProvider(_ provider: SessionConfigurationProvider) -> Self {
        sessionConfigurationProvider = provider
        return self
    }

    /// Sets the logging strategy for the logger.
    ///
    /// - Parameter strategy: The logging strategy to set.
    /// - Returns: The logger instance with the updated logging strategy.
    @discardableResult
    public func log(_ strategy: LogStrategy) -> Self {
        logStrategy = strategy
        return self
    }

    /// Resets the configuration of the network builder to its default state.
    ///
    /// This method clears any custom SSL pinning policy, metric interceptor, network strategy,
    /// and sets default values for execution and observation queues, and network reachability.
    ///
    /// - Returns: The modified instance of the network builder with the default configuration.
    @discardableResult
    public func applyDefaultConfiguration() -> Self {
        sslPinningPolicy = .disabled
        reportMetricStrategy = .disabled
        automationMode = .disabled
        recordResponseMode = .disabled
        logStrategy = .disabled
        executionQueue = DefaultDispatchQueue.executionQueue
        observationQueue = DefaultDispatchQueue.observationQueue
        networkReachability = NetworkReachability.shared
        sessionConfigurationProvider = DefaultSessionConfigurationProvider.ephemeral
        if let session = try? createNetworkSession() { self.session = session }
        return self
    }

    /// Creates a logger based on the configured logging strategy.
    ///
    /// - Returns: A `LoggerInterface` instance based on the logging strategy.
    ///            Returns `nil` if logging is disabled, the shared default logger
    ///            if logging is enabled, or a custom logger if provided.
    func createLogger() -> LoggerInterface? {
        switch logStrategy {
        case .disabled:
            return nil
        case .enabled:
            return DefaultLogger.shared
        case let .custom(logger):
            return logger
        }
    }

    /// Creates and returns a network session conforming to `SessionType`.
    ///
    /// This method initializes a URLSession with the provided configuration and a custom delegate (`SessionProxyDelegate`).
    /// The delegate is responsible for handling SSL pinning, metric task reporting, and logging.
    ///
    /// - Throws: A `NetworkError` if the session cannot be created or if there is an issue with SSL pinning.
    /// - Returns: An instance conforming to `SessionType`.
    func createNetworkSession() throws -> SessionType {
        let delegate = SessionProxyDelegate(sslPinningPolicy: sslPinningPolicy,
                                            reportMetricStrategy: reportMetricStrategy,
                                            loggerInterface: createLogger())

        guard let session = URLSession(configuration: sessionConfigurationProvider.sessionConfig,
                                       delegate: delegate,
                                       delegateQueue: nil) as? SessionType
        else {
            throw NetworkError.invalidSession
        }
        return session
    }
}
