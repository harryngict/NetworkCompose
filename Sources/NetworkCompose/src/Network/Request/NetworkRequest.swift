//
//  NetworkRequest.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

public class NetworkRequest<T: Codable> {
    private var path: String
    private var method: NetworkMethod
    private var queryParameters: [String: Any]?
    private var headers: [String: String]
    private var bodyEncoding: BodyEncoding
    private var timeoutInterval: TimeInterval
    private var responseDecoder: ResponseDecoder
    private var cachePolicy: NetworkCachePolicy
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
    @discardableResult
    public func setQueryParameters(_ parameters: [String: Any]?) -> Self {
        queryParameters = parameters
        return self
    }

    /// Sets the HTTP headers for the network request.
    ///
    /// - Parameter headers: The headers to include in the request.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func setHeaders(_ headers: [String: String]) -> Self {
        self.headers = headers
        return self
    }

    /// Sets the encoding type for the request body.
    ///
    /// - Parameter bodyEncoding: The encoding type for the request body.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func setBodyEncoding(_ bodyEncoding: BodyEncoding) -> Self {
        self.bodyEncoding = bodyEncoding
        return self
    }

    /// Sets the timeout interval for the network request.
    ///
    /// - Parameter timeoutInterval: The timeout interval for the request.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func setTimeoutInterval(_ timeoutInterval: TimeInterval) -> Self {
        self.timeoutInterval = timeoutInterval
        return self
    }

    /// Sets the response decoder for the network request.
    ///
    /// - Parameter responseDecoder: The response decoder for parsing the network response.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func setResponseDecoder(_ responseDecoder: ResponseDecoder) -> Self {
        self.responseDecoder = responseDecoder
        return self
    }

    /// Sets the cache policy for the network request.
    ///
    /// - Parameter cachePolicy: The cache policy for the request.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func setCachePolicy(_ cachePolicy: NetworkCachePolicy) -> Self {
        self.cachePolicy = cachePolicy
        return self
    }

    /// Sets the flag indicating whether the network request requires re-authentication.
    ///
    /// - Parameter requiresReAuthentication: A flag indicating whether the request requires re-authentication.
    /// - Returns: The builder instance for method chaining.
    @discardableResult
    public func setRequiresReAuthentication(_ requiresReAuthentication: Bool) -> Self {
        self.requiresReAuthentication = requiresReAuthentication
        return self
    }

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
