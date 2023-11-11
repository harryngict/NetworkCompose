//
//  NetworkRequest.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 20/11/23.
//

import Foundation

/// A structure representing a network request with generic response handling.
///
/// Use this structure to define a network request with various parameters such as path, method,
/// query parameters, headers, and more.
///
/// - Note: Conform the `SuccessType` associated type to `Codable` to facilitate automatic response decoding.
///
public struct NetworkRequest<T: Codable>: NetworkRequestInterface {
    /// The type representing the successful response, conforming to `Codable`.
    public typealias SuccessType = T

    /// The path of the request endpoint.
    public var path: String
    /// The HTTP method of the request.
    public var method: NetworkMethod
    /// The query parameters to include in the request.
    public var queryParameters: [String: Any]?
    /// The headers to include in the request.
    public var headers: [String: String]
    /// Encoding type for the request body.
    public var bodyEncoding: BodyEncoding
    /// The timeout interval for the request.
    public var timeoutInterval: TimeInterval
    /// The response decoder used to parse the network response.
    public var responseDecoder: ResponseDecoder
    /// The cache policy for the request.
    public var cachePolicy: NetworkCachePolicy
    /// A flag indicating whether the request requires re-authentication.
    public var requiresReAuthentication: Bool

    /// Initializes a `NetworkRequest` instance with the specified parameters.
    ///
    /// - Parameters:
    ///   - path: The path of the request endpoint.
    ///   - method: The HTTP method of the request.
    ///   - queryParameters: The query parameters to include in the request.
    ///   - headers: The headers to include in the request.
    ///   - body: The body data to include in the request, if applicable.
    ///   - timeoutInterval: The timeout interval for the request.
    ///   - cachePolicy: The cache policy for the request.
    ///   - responseDecoder: The response decoder used to parse the network response.
    ///   - requiresReAuthentication: A flag indicating whether the request requires re-authentication.
    public init(path: String,
                method: NetworkMethod,
                queryParameters: [String: Any]? = nil,
                headers: [String: String] = [:],
                bodyEncoding: BodyEncoding = .json,
                timeoutInterval: TimeInterval = 60.0,
                cachePolicy: NetworkCachePolicy = .ignoreCache,
                responseDecoder: ResponseDecoder = JSONDecoder(),
                requiresReAuthentication: Bool = false)
    {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.headers = headers
        self.bodyEncoding = bodyEncoding
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        self.responseDecoder = responseDecoder
        self.requiresReAuthentication = requiresReAuthentication
    }
}
