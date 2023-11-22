//
//  NetworkRequestBuilder.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

/// A builder class for creating instances of `NetworkRequestImp`.
///
/// Use this class to construct a `NetworkRequestImp` with customizable parameters.
///
/// - Note: Example usage:
///   ```swift
///   let request = NetworkRequestBuilder<MyResponseType>(path: "/api/endpoint", method: .get)
///       .setQueryParameters(["param": "value"])
///       .setHeaders(["Authorization": "Bearer token"])
///       .setBodyEncoding(.urlEncoded)
///       .setTimeoutInterval(30.0)
///       .setResponseDecoder(customDecoder)
///       .setCachePolicy(.useCache)
///       .setRequiresReAuthentication(true)
///       .build()
///   ```
public class NetworkRequestBuilder<T: Codable> {
    /// The endpoint path for the network request.
    private var path: String
    /// The HTTP method for the network request.
    private var method: NetworkMethod
    /// The query parameters for the network request.
    private var queryParameters: [String: Any]?
    /// The HTTP headers for the network request.
    private var headers: [String: String]
    /// The encoding type for the request body.
    private var bodyEncoding: BodyEncoding
    /// The timeout interval for the network request.
    private var timeoutInterval: TimeInterval
    /// The response decoder for parsing the network response.
    private var responseDecoder: ResponseDecoder
    /// The cache policy for the network request.
    private var cachePolicy: NetworkCachePolicy
    /// A flag indicating whether the network request requires re-authentication.
    private var requiresReAuthentication: Bool

    /// Initializes a `NetworkRequestBuilder` instance with the specified path and method.
    ///
    /// - Parameters:
    ///   - path: The endpoint path for the network request.
    ///   - method: The HTTP method for the network request.
    public init(path: String, method: NetworkMethod) {
        self.path = path
        self.method = method
        headers = [:]
        bodyEncoding = .json
        timeoutInterval = 60.0
        cachePolicy = .ignoreCache
        responseDecoder = JSONDecoder()
        requiresReAuthentication = false
    }

    /// Sets the query parameters for the network request.
    ///
    /// - Parameter parameters: The query parameters to include in the request.
    /// - Returns: The builder instance for method chaining.
    public func setQueryParameters(_ parameters: [String: Any]?) -> Self {
        queryParameters = parameters
        return self
    }

    /// Sets the HTTP headers for the network request.
    ///
    /// - Parameter headers: The headers to include in the request.
    /// - Returns: The builder instance for method chaining.
    public func setHeaders(_ headers: [String: String]) -> Self {
        self.headers = headers
        return self
    }

    /// Sets the encoding type for the request body.
    ///
    /// - Parameter bodyEncoding: The encoding type for the request body.
    /// - Returns: The builder instance for method chaining.
    public func setBodyEncoding(_ bodyEncoding: BodyEncoding) -> Self {
        self.bodyEncoding = bodyEncoding
        return self
    }

    /// Sets the timeout interval for the network request.
    ///
    /// - Parameter timeoutInterval: The timeout interval for the request.
    /// - Returns: The builder instance for method chaining.
    public func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> Self {
        self.timeoutInterval = timeoutInterval
        return self
    }

    /// Sets the response decoder for the network request.
    ///
    /// - Parameter responseDecoder: The response decoder for parsing the network response.
    /// - Returns: The builder instance for method chaining.
    public func setResponseDecoder(_ responseDecoder: ResponseDecoder) -> Self {
        self.responseDecoder = responseDecoder
        return self
    }

    /// Sets the cache policy for the network request.
    ///
    /// - Parameter cachePolicy: The cache policy for the request.
    /// - Returns: The builder instance for method chaining.
    public func setCachePolicy(_ cachePolicy: NetworkCachePolicy) -> Self {
        self.cachePolicy = cachePolicy
        return self
    }

    /// Sets the flag indicating whether the network request requires re-authentication.
    ///
    /// - Parameter requiresReAuthentication: A flag indicating whether the request requires re-authentication.
    /// - Returns: The builder instance for method chaining.
    public func setRequiresReAuthentication(_ requiresReAuthentication: Bool) -> Self {
        self.requiresReAuthentication = requiresReAuthentication
        return self
    }

    /// Builds and returns a `NetworkRequestImp` instance with the configured parameters.
    ///
    /// - Returns: A fully configured `NetworkRequestImp` instance.
    public func build() -> NetworkRequestImp<T> {
        return NetworkRequestImp(
            path: path,
            method: method,
            queryParameters: queryParameters,
            headers: headers,
            bodyEncoding: bodyEncoding,
            timeoutInterval: timeoutInterval,
            cachePolicy: cachePolicy,
            responseDecoder: responseDecoder,
            requiresReAuthentication: requiresReAuthentication
        )
    }
}
