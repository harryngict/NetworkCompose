//
//  NetworkError.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

/// Enumerates network-related errors.
///
/// This enumeration provides a set of network-related error cases that can be thrown during network operations.
///
/// Example Usage:
///
/// ```swift
/// do {
///     throw NetworkError.badURLComponents(components)
/// } catch let error as NetworkError {
///     print("Error Code: \(error.errorCode)")
///     print("Localized Description: \(error.localizedDescription)")
/// }
/// ```
public enum NetworkError: Error, Codable, Sendable {
    /// Represents an error when the URL is malformed.
    ///
    /// - Parameters:
    ///   - url: The malformed URL.
    ///   - path: The path associated with the malformed URL.
    case badURL(URL, String)

    /// Represents an error when the URL components are invalid.
    ///
    /// - Parameter components: The invalid URL components.
    case badURLComponents(URLComponents)

    /// Represents an error when the session is invalid.
    case invalidSession

    /// Represents an error when the response is invalid.
    case invalidResponse

    /// Represents an error when the internet connection is lost.
    case lostInternetConnection

    /// Represents a generic network error with an optional status code and message.
    ///
    /// - Parameters:
    ///   - code: The optional status code associated with the network error.
    ///   - msg: The optional message providing additional details about the network error.
    case networkError(Int?, String?)

    /// The error code associated with the specific case.
    ///
    /// This property provides a unique error code for each case in the `NetworkError` enumeration.
    public var errorCode: Int {
        switch self {
        case .badURL: return -101
        case .badURLComponents: return -102
        case .invalidSession: return -103
        case .invalidResponse: return -104
        case .lostInternetConnection: return -105
        case let .networkError(code, _): return code ?? -106
        }
    }

    /// A localized description of the error.
    ///
    /// This property provides a human-readable description of the error, suitable for displaying to users.
    public var localizedDescription: String {
        switch self {
        case let .badURL(url, path): return "Bad URL base: \(url) path: \(path)"
        case let .badURLComponents(components): return "Bad URL components: \(components)"
        case .invalidSession: return "Invalid session"
        case .invalidResponse: return "Invalid response"
        case .lostInternetConnection: return "The network connection was lost"
        case let .networkError(_, msg): return msg ?? "Network error with code: \(errorCode)"
        }
    }
}
