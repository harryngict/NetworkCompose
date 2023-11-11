//
//  String+Extensions.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

/// An extension to `String` providing additional functionality related to URL parsing.
public extension String {
    /// Extracts the host from the receiver, assuming it represents a valid URL string.
    ///
    /// This method converts the receiver string to a URL and extracts the host component.
    ///
    /// - Returns: The extracted host, or `nil` if the URL is invalid.
    ///
    /// - Example:
    ///   ```swift
    ///   let urlString = "https://www.example.com/path"
    ///   if let host = urlString.extractHost() {
    ///       print("Host: \(host)")
    ///   } else {
    ///       print("Invalid URL")
    ///   }
    ///   ```
    func extractHost() -> String? {
        guard let url = URL(string: self), let host = url.host else {
            return nil
        }
        return host
    }
}
