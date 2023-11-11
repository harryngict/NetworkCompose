//
//  RequestMetric.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A struct representing metrics related to a network request.
public struct RequestMetric: Codable, Sendable {
    /// The URL of the network request.
    public var url: URL?

    /// The HTTP method used in the network request.
    public var httpMethod: String?

    /// The headers included in the network request.
    public var headers: [String: String]?

    /// The cache policy used in the network request.
    public var cachePolicy: URLRequest.CachePolicy {
        rawCachePolicy.flatMap(URLRequest.CachePolicy.init) ?? .useProtocolCachePolicy
    }

    /// The timeout interval for the network request.
    public var timeout: TimeInterval

    /// Additional options for the network request.
    public var options: Options

    /// The content type of the network request.
    public var contentType: ContentTypeMetric? {
        headers?["Content-Type"].flatMap(ContentTypeMetric.init)
    }

    private var rawCachePolicy: UInt?

    /// Initializes a `RequestMetric` instance based on a given URLRequest.
    ///
    /// - Parameter urlRequest: The URLRequest from which to extract metrics.
    public init(_ urlRequest: URLRequest) {
        url = urlRequest.url
        headers = urlRequest.allHTTPHeaderFields
        httpMethod = urlRequest.httpMethod
        rawCachePolicy = urlRequest.cachePolicy.rawValue
        timeout = urlRequest.timeoutInterval
        options = Options(urlRequest)
    }

    /// A set of options for customizing the behavior of a network request.
    public struct Options: OptionSet, Hashable, Codable, Sendable {
        public let rawValue: Int8

        /// Initializes an `Options` instance with a given raw value.
        ///
        /// - Parameter rawValue: The raw value representing the options.
        public init(rawValue: Int8) { self.rawValue = rawValue }

        /// Indicates whether the network request allows cellular access.
        public static let allowsCellularAccess = Options(rawValue: 1 << 0)

        /// Indicates whether the network request should handle cookies.
        public static let httpShouldHandleCookies = Options(rawValue: 1 << 1)

        /// Indicates whether the network request should use pipelining.
        public static let httpShouldUsePipelining = Options(rawValue: 1 << 2)

        /// Initializes an `Options` instance based on a given URLRequest.
        ///
        /// - Parameter request: The URLRequest from which to extract options.
        init(_ request: URLRequest) {
            self = []
            if request.allowsCellularAccess { insert(.allowsCellularAccess) }
            if request.httpShouldHandleCookies { insert(.httpShouldHandleCookies) }
            if request.httpShouldUsePipelining { insert(.httpShouldUsePipelining) }
        }
    }
}
