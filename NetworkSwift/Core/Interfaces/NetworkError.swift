//
//  NetworkError.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

/// An enumeration representing network-related errors.
///
/// Example usage:
/// ```swift
/// do {
///     throw NetworkError.badURLComponents(components)
/// } catch let error as NetworkError {
///     print("Error Code: \(error.errorCode)")
///     print("Localized Description: \(error.localizedDescription)")
/// }
/// ```
public enum NetworkError: Error {
    /// Represents an error when the URL is malformed.
    case badURL(URL, String)
    /// Represents an error when the URL components are invalid.
    case badURLComponents(URLComponents)
    /// Represents an error when the session is invalid.
    case invalidSession
    /// Represents an error when the response is invalid.
    case invalidResponse
    /// Represents a generic network error with an optional status code and message.
    case networkError(Int?, String?)

    /// The error code associated with the specific case.
    public var errorCode: Int {
        switch self {
        case .badURL: return -101
        case .badURLComponents: return -102
        case .invalidSession: return -103
        case .invalidResponse: return -104
        case let .networkError(code, _): return code != nil ? code! : -105
        }
    }

    /// A localized description of the error.
    public var localizedDescription: String {
        switch self {
        case let .badURL(url, path): return "Bad URL base: \(url) path: \(path)"
        case let .badURLComponents(components): return "Bad URL components: \(components)"
        case .invalidSession: return "Invalid session"
        case .invalidResponse: return "Invalid response"
        case let .networkError(_, msg): return msg != nil ? msg! : "Network error with code: \(errorCode)"
        }
    }
}
