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
    public var options: Options
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
        options = Options(urlRequest)
    }

    public struct Options: OptionSet, Hashable, Codable, Sendable {
        public let rawValue: Int8
        public init(rawValue: Int8) { self.rawValue = rawValue }
        public static let allowsCellularAccess = Options(rawValue: 1 << 0)
        public static let httpShouldHandleCookies = Options(rawValue: 1 << 1)
        public static let httpShouldUsePipelining = Options(rawValue: 1 << 2)

        init(_ request: URLRequest) {
            self = []
            if request.allowsCellularAccess { insert(.allowsCellularAccess) }
            if request.httpShouldHandleCookies { insert(.httpShouldHandleCookies) }
            if request.httpShouldUsePipelining { insert(.httpShouldUsePipelining) }
        }
    }
}
