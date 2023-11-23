//
//  ResponseErrorMetric.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A struct representing metrics related to a network response error.
public struct ResponseErrorMetric: Codable, Sendable {
    /// The error code associated with the network response error.
    public var code: Int

    /// The error domain associated with the network response error.
    public var domain: String

    /// A debug description providing additional information about the network response error.
    public var debugDescription: String

    /// Initializes a `ResponseErrorMetric` instance based on a given Swift error.
    ///
    /// - Parameter error: The Swift error from which to extract metrics.
    public init(_ error: Swift.Error) {
        let error = error as NSError
        code = error.code == 0 ? -1 : error.code
        domain = error.domain
        debugDescription = error.debugDescription
    }
}
