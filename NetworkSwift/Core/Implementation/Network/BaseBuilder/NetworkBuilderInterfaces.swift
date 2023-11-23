//
//  NetworkBuilderInterfaces.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public protocol NetworkBuilderInterfaces: AnyObject {
    associatedtype SessionType: NetworkSession

    /// The base URL for network requests.
    var baseURL: URL { get set }

    /// The network session to use for requests.
    var session: SessionType { get set }

    /// The security trust policy for SSL pinning.
    var sslPinningPolicy: NetworkSSLPinningPolicy { get set }

    /// The metrics collector object for collecting network metrics.
    var metricInterceptor: NetworkMetricInterceptor? { get set }

    /// The network reachability object for monitoring internet connection status.
    var networkReachability: NetworkReachability { get set }

    /// The dispatch queue for executing network requests.
    var executeQueue: NetworkDispatchQueue { get set }

    /// The dispatch queue for observing and handling network events.
    var observeQueue: NetworkDispatchQueue { get set }

    /// Initializes a network kit builder with a base URL and a default session.
    init(baseURL: URL,
         session: SessionType,
         networkReachability: NetworkReachability,
         executeQueue: NetworkDispatchQueue,
         observeQueue: NetworkDispatchQueue)

    /// Sets the security trust for SSL pinning.
    ///
    /// - Parameter sslPinningPolicy: The security trust object for SSL pinning.
    /// - Returns: The builder instance for method chaining.
    ///
    /// - Throws: A `NetworkError` if the session cannot be created.
    func setSSLPinningPolicy(_ sslPinningPolicy: NetworkSSLPinningPolicy) throws -> Self

    /// Sets the metrics collector for network metrics.
    ///
    /// - Parameter metricInterceptor: The metrics collector object for collecting network metrics.
    /// - Returns: The builder instance for method chaining.
    ///
    /// - Throws: A `NetworkError` if the session cannot be created.
    func setMetricInterceptor(_ metricInterceptor: NetworkMetricInterceptor) throws -> Self

    /// Sets the custom network reachability object.
    ///
    /// - Parameter reachability: The custom network reachability object.
    /// - Returns: The builder instance for method chaining.
    func setNetworkReachability(_ reachability: NetworkReachability) -> Self

    /// Sets the custom dispatch queue for executing network requests.
    ///
    /// - Parameter executeQueue: The custom dispatch queue for executing network requests.
    /// - Returns: The builder instance for method chaining.
    func setExecuteQueue(_ executeQueue: NetworkDispatchQueue) -> Self

    /// Sets the custom dispatch queue for observing and handling network events.
    ///
    /// - Parameter observeQueue: The custom dispatch queue for observing and handling network events.
    /// - Returns: The builder instance for method chaining.
    func setObserveQueue(_ observeQueue: NetworkDispatchQueue) -> Self
}
