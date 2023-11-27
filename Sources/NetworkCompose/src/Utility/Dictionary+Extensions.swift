//
//  Dictionary+Extensions.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    /// Converts the dictionary into a URL-encoded query string.
    ///
    /// - Returns: A URL-encoded query string representation of the dictionary, where keys and values are joined by '=' and pairs are joined by '&'.
    func urlEncodedQueryString() -> String {
        return map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    /// Converts the key-value pairs of the dictionary into a string with sorted keys.
    ///
    /// - Returns: A string representation of the dictionary's key-value pairs, where keys and values are concatenated and sorted.
    func sortedKeyValueString() -> String {
        guard !isEmpty else {
            return ""
        }

        // Sort the keys alphabetically
        let sortedKeys = keys.sorted()

        // Concatenate key-value pairs into a string
        let result = sortedKeys.map { key in
            guard let value = self[key] else { return "" }
            return "\(key)_\(value)"
        }.joined(separator: "_")

        return result
    }
}
