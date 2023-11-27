//
//  Request.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 20/11/23.
//

import Foundation

public struct Request<T: Codable>: RequestInterface {
    /// The type representing the successful response, conforming to `Codable`.
    public typealias SuccessType = T

    public var path: String
    public var method: NetworkMethod
    public var queryParameters: [String: Any]?
    public var headers: [String: String]
    public var bodyEncoding: BodyEncoding
    public var timeoutInterval: TimeInterval
    public var responseDecoder: ResponseDecoder
    public var cachePolicy: NetworkCachePolicy
    public var requiresReAuthentication: Bool

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
