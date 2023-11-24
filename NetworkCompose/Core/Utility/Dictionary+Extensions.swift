//
//  Dictionary+Extensions.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

/// Extends a dictionary to provide a method for encoding to URL-encoded format.
extension Dictionary where Key == String, Value == Any {
    /// Converts the dictionary into a URL-encoded query string.
    ///
    /// The resulting query string is suitable for appending to a URL or using as the body of an HTTP request.
    ///
    /// - Returns: A URL-encoded query string.
    ///
    /// - Note: This method filters out dictionary entries where the value's description is empty to ensure that the resulting query string does not contain empty values.
    ///
    /// - Warning: The encoding may not be suitable for certain characters or non-string values.
    ///
    /// - Complexity: O(n), where n is the number of key-value pairs in the dictionary.
    ///
    /// - SeeAlso: [URL Encoding](https://developer.apple.com/documentation/foundation/nsurl#urlencoding)
    func urlEncodedQueryString() -> String {
        return map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}
