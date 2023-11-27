//
//  UniqueKey.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 26/11/23.
//

import Foundation

/// A struct representing a unique key for identifying network requests based on path, method, and query parameters.
public struct UniqueKey {
    /// The unique key generated based on the provided path, method, and optional query parameters.
    public let key: String

    /// Initializes a `UniqueKey` instance with the specified components.
    ///
    /// - Parameters:
    ///   - path: The path of the network request.
    ///   - method: The HTTP method of the network request.
    ///   - queryParameters: Optional query parameters for the network request. Default is `nil`.
    public init(path: String, method: String, queryParameters: [String: Any]? = nil) {
        var value: String
        if let queryParameters = queryParameters {
            let query = queryParameters.sortedKeyValueString()
            value = "\(method)_\(path)_\(query)"
        } else {
            value = "\(method)_\(path)"
        }
        key = value.replacingOccurrences(of: "/", with: "_")
    }
}

extension UniqueKey: Hashable {
    /// Checks whether two `UniqueKey` instances are equal by comparing their keys.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `UniqueKey`.
    ///   - rhs: The right-hand side `UniqueKey`.
    /// - Returns: `true` if the keys are equal; otherwise, `false`.
    public static func == (lhs: UniqueKey, rhs: UniqueKey) -> Bool {
        return lhs.key == rhs.key
    }

    /// Hashes the `UniqueKey` instance using its key value.
    ///
    /// - Parameter hasher: The hasher to use for combining the hash values.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}
