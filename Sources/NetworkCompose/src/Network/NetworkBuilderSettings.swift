//
//  NetworkBuilderSettings.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public class NetworkBuilderSettings<SessionType: NetworkSession> {
    /// The base URL for the network requests.
    var baseURL: URL

    /// The session used for network communication conforming to the specified session type.
    var session: SessionType

    /// The SSL pinning policy to enhance security in network communication.
    var sslPinningPolicy: SSLPinningPolicy = .disabled

    /// The strategy for reporting metrics related to network tasks.
    var reportMetricStrategy: ReportMetricStrategy = .disabled

    /// The strategy for logging network events.
    var loggerStrategy: LoggerStrategy = .disabled

    /// The delegate for handling network session events.
    var sessionProxyDelegate: SessionProxyDelegate?

    /// The type of session configuration to use.
    var sessionConfigurationType: SessionConfigurationType = .ephemeral

    /// Interface for monitoring network reachability.
    var networkReachability: NetworkReachabilityInterface = NetworkReachability.shared

    /// The queue on which network operations are executed.
    var executionQueue: DispatchQueueType = DefaultDispatchQueue.executionQueue

    /// The queue on which network events are observed.
    var observationQueue: DispatchQueueType = DefaultDispatchQueue.observationQueue

    /// The strategy for mocking network events, useful for testing or simulating network behavior.
    var automationMode: AutomationMode = .disabled

    /// The mode for recording responses during network operations.
    var recordResponseMode: RecordResponseMode = .disabled

    /// Initializes a new instance of `NetworkBuilderSettings`.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The session used for network communication.
    public init(baseURL: URL,
                session: SessionType = URLSession.shared)
    {
        self.baseURL = baseURL
        self.session = session
    }

    /// Convenience initializer for creating a `NetworkBuilderSettings` instance with a custom session configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - sessionConfigurationType: The type of session configuration to use.
    ///   - sessionProxyDelegate: The delegate to handle network session events.
    /// - Throws: `NetworkError.invalidSession` if the session cannot be created.
    public convenience init(baseURL: URL,
                            sessionProxyDelegate: SessionProxyDelegate,
                            sessionConfigurationType: SessionConfigurationType = .ephemeral) throws
    {
        guard let session = URLSession(configuration: sessionConfigurationType.sessionConfig,
                                       delegate: sessionProxyDelegate,
                                       delegateQueue: nil) as? SessionType
        else {
            throw NetworkError.invalidSession
        }

        self.init(baseURL: baseURL, session: session)
        self.sessionProxyDelegate = sessionProxyDelegate
        self.sessionConfigurationType = sessionConfigurationType
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
    /// - Note: This method supports method chaining, allowing you to conveniently set the storage strategy and perform additional configurations in a single line.
    /// - SeeAlso: `RecordResponseMode` for available modes and customization options.
    @discardableResult
    public func recordResponseForTesting(_ mode: RecordResponseMode) -> Self {
        recordResponseMode = mode
        return self
    }

    /// Sets the security trust for SSL pinning and refreshes the session accordingly.
    ///
    /// - Parameter sslPinningPolicy: The security trust object for SSL pinning.
    /// - Returns: The builder instance for method chaining.
    ///
    /// - Throws: A `NetworkError` if the session cannot be created.
    @discardableResult
    public func sslPinningPolicy(_ sslPinningPolicy: SSLPinningPolicy) -> Self {
        self.sslPinningPolicy = sslPinningPolicy
        try? refreshSession()
        return self
    }

    /// Sets the strategy for reporting metrics related to network tasks and refreshes the session accordingly.
    ///
    /// Use this method to configure the strategy for reporting metrics associated with network tasks.
    /// The provided `strategy` parameter defines how metrics should be reported.
    ///
    /// - Parameter strategy: The strategy for reporting metrics related to network tasks.
    /// - Returns: An instance of the same type to support method chaining.
    @discardableResult
    public func reportMetric(_ strategy: ReportMetricStrategy) -> Self {
        reportMetricStrategy = strategy
        try? refreshSession()
        return self
    }

    /// Sets the session configuration provider for the network and refreshes the session accordingly.
    ///
    /// Use this method to provide a custom `SessionConfigurationType` to configure the network session.
    ///
    /// - Parameter type: The session configuration provider.
    /// - Returns: An instance of the network with the updated session configuration provider.
    @discardableResult
    public func sessionConfigurationType(_ type: SessionConfigurationType) -> Self {
        sessionConfigurationType = type
        try? refreshSession()
        return self
    }

    /// Sets the logging strategy for the logger and refreshes the session accordingly.
    ///
    /// - Parameter strategy: The logging strategy to set.
    /// - Returns: The logger instance with the updated logging strategy.
    @discardableResult
    public func logger(_ strategy: LoggerStrategy) -> Self {
        loggerStrategy = strategy
        try? refreshSession()
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
        sslPinningPolicy = .disabled
        reportMetricStrategy = .disabled
        automationMode = .disabled
        recordResponseMode = .disabled
        loggerStrategy = .disabled
        executionQueue = DefaultDispatchQueue.executionQueue
        observationQueue = DefaultDispatchQueue.observationQueue
        networkReachability = NetworkReachability.shared
        sessionConfigurationType = .ephemeral
        sessionProxyDelegate = nil
        try? refreshSession()
        return self
    }

    /// Gets a logger based on the configured logging strategy.
    ///
    /// - Returns: A `LoggerInterface` instance based on the logging strategy.
    func getLogger() -> LoggerInterface? {
        switch loggerStrategy {
        case .disabled:
            return nil
        case .enabled:
            return DefaultLogger.shared
        case let .custom(logger):
            return logger
        }
    }

    /// Updates the network session with the latest configuration and options.
    ///
    /// If any of the following properties change: `sslPinningPolicy`, `reportMetricStrategy`, `loggerStrategy`
    /// or `sessionConfigurationType` , it is necessary to call this method to apply the changes to the session.
    ///
    /// - Returns: An updated `SessionType` instance.
    /// - Throws: `NetworkError.invalidSession` if the updated session cannot be created.
    func refreshSession() throws {
        if sessionProxyDelegate == nil {
            sessionProxyDelegate = SessionProxyDelegate(sslPinningPolicy: sslPinningPolicy,
                                                        reportMetricStrategy: reportMetricStrategy,
                                                        loggerInterface: getLogger())
        } else {
            sessionProxyDelegate?.update(sslPinningPolicy: sslPinningPolicy,
                                         reportMetricStrategy: reportMetricStrategy,
                                         loggerInterface: getLogger())
        }

        guard let session = URLSession(configuration: sessionConfigurationType.sessionConfig,
                                       delegate: sessionProxyDelegate,
                                       delegateQueue: nil) as? SessionType
        else {
            throw NetworkError.invalidSession
        }
        self.session = session
    }
}
