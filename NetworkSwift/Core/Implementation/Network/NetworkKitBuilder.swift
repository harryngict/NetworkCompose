//
//  NetworkKitBuilder.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

import Foundation

/// A builder for constructing instances of `NetworkKitImp`.
///
/// This builder provides a convenient way to create and configure a `NetworkKitImp` instance for making network requests.
///
/// ## Example Usage
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let networkKit = try? NetworkKitBuilder(baseURL: baseURL)
///     .setSecurityTrust(yourSecurityTrust)
///     .build()
/// ```
public class NetworkKitBuilder<SessionType: NetworkSession> {
    /// The base URL for network requests.
    private let baseURL: URL

    /// The network session to use for requests.
    private var session: SessionType

    /// The security trust object for SSL pinning.
    private var securityTrust: NetworkSecurityTrust?

    /// The metrics collector object for collecting network metrics.
    private var metricsCollector: NetworkMetricsCollector?

    /// The network reachability object for monitoring internet connection status.
    private var networkReachability: NetworkReachability

    /// The dispatch queue for executing network requests.
    private var executeQueue: NetworkDispatchQueue

    /// The dispatch queue for observing and handling network events.
    private var observeQueue: NetworkDispatchQueue

    /// Initializes a `NetworkKitBuilder` with a base URL and a default session.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    public init(baseURL: URL,
                session: SessionType = URLSession.shared,
                networkReachability: NetworkReachability = NetworkReachabilityImp.shared,
                executeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.executeQueue,
                observeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.observeQueue)
    {
        self.baseURL = baseURL
        self.session = session
        self.networkReachability = networkReachability
        self.executeQueue = executeQueue
        self.observeQueue = observeQueue
    }

    /// Sets the security trust for SSL pinning.
    ///
    /// - Parameter securityTrust: The security trust object for SSL pinning.
    /// - Returns: The builder instance for method chaining.
    ///
    /// - Throws: A `NetworkError` if the session cannot be created.
    public func setSecurityTrust(_ securityTrust: NetworkSecurityTrust) throws -> Self {
        self.securityTrust = securityTrust
        session = try createNetworkSession()
        return self
    }

    /// Sets the metrics collector for network metrics.
    ///
    /// - Parameter metricsCollector: The metrics collector object for collecting network metrics.
    /// - Returns: The builder instance for method chaining.
    ///
    /// - Throws: A `NetworkError` if the session cannot be created.
    public func setMetricsCollector(_ metricsCollector: NetworkMetricsCollector) throws -> Self {
        self.metricsCollector = metricsCollector
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

    /// Builds and returns a `NetworkKitImp` instance with the configured parameters.
    ///
    /// - Returns: A fully configured `NetworkKitImp` instance.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public func build() -> NetworkKitImp<SessionType> {
        return NetworkKitImp(
            baseURL: baseURL,
            session: session,
            networkReachability: networkReachability,
            executeQueue: executeQueue,
            observeQueue: observeQueue
        )
    }

    /// Performs a network request with a completion handler.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called when the request is complete.
    public func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        build().request(request, andHeaders: headers,
                        retryPolicy: retryPolicy,
                        completion: completion)
    }
}

private extension NetworkKitBuilder {
    /// Creates and returns a network session with the configured parameters.
    ///
    /// This method initializes a network session with the provided metrics collector and security trust,
    /// and returns an instance conforming to the specified `SessionType`.
    ///
    /// - Throws: A `NetworkError.invalidSession` if the session cannot be created.
    ///
    /// - Returns: A fully configured network session conforming to the specified `SessionType`.
    ///
    /// - Parameter metricsCollector: An optional `NetworkMetricsCollector` for collecting network metrics.
    /// - Parameter securityTrust: An optional `NetworkSecurityTrust` for SSL pinning.
    ///
    /// - Important: If a `securityTrust` is provided, SSL pinning will be enabled.
    ///
    /// - Note: This method is used internally by the `NetworkKitBuilder` to create the network session.
    func createNetworkSession() throws -> SessionType {
        do {
            let delegate = NetworkSessionProxyDelegate(metricsCollector: metricsCollector, securityTrust: securityTrust)

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
