//
//  NetworkError.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation


public enum NetworkError: Error, Sendable, Equatable, Hashable {
  
    case badURL(URL, String)
    case badURLComponents(URLComponents)
    case invalidSession
    case invalidResponse
    case lostInternetConnection
    case networkError(Int?, String?)

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
