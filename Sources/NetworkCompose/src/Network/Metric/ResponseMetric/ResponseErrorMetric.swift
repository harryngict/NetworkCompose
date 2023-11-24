//
//  ResponseErrorMetric.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public struct ResponseErrorMetric: Codable, Sendable {
    public var code: Int
    public var domain: String
    public var debugDescription: String

    public init(_ error: Swift.Error) {
        let error = error as NSError
        code = error.code == 0 ? -1 : error.code
        domain = error.domain
        debugDescription = error.debugDescription
    }
}
