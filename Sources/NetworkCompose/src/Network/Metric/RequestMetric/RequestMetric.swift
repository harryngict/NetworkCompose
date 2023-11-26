//
//  RequestMetric.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public struct RequestMetric: Codable, Sendable {
    public var url: URL?
    public var httpMethod: String?
    public var headers: [String: String]?
    public var cachePolicy: URLRequest.CachePolicy {
        rawCachePolicy.flatMap(URLRequest.CachePolicy.init) ?? .useProtocolCachePolicy
    }

    public var timeout: TimeInterval
    public var contentType: ContentTypeMetric? {
        headers?["Content-Type"].flatMap(ContentTypeMetric.init)
    }

    private var rawCachePolicy: UInt?

    public init(_ urlRequest: URLRequest) {
        url = urlRequest.url
        headers = urlRequest.allHTTPHeaderFields
        httpMethod = urlRequest.httpMethod
        rawCachePolicy = urlRequest.cachePolicy.rawValue
        timeout = urlRequest.timeoutInterval
    }
}
