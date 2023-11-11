//
//  ResponseMetric.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A struct representing metrics related to a network response.
public struct ResponseMetric: Hashable, Codable, Sendable {
    /// The HTTP status code of the network response.
    public var statusCode: Int?

    /// The headers included in the network response.
    public var headers: [String: String]?

    /// The content type of the network response.
    public var contentType: ContentTypeMetric? {
        headers?["Content-Type"].flatMap(ContentTypeMetric.init)
    }

    /// A Boolean value indicating whether the network response is successful.
    public var isSuccess: Bool {
        (100 ..< 400).contains(statusCode ?? 200)
    }

    /// Initializes a `ResponseMetric` instance based on a given URLResponse.
    ///
    /// - Parameter urlResponse: The URLResponse from which to extract metrics.
    public init(_ urlResponse: URLResponse) {
        let httpResponse = urlResponse as? HTTPURLResponse
        statusCode = httpResponse?.statusCode
        headers = httpResponse?.allHeaderFields as? [String: String]
    }
}
