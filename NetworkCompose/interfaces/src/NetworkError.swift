//
//  NetworkError.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 11/11/23.
//

import Foundation

// MARK: - NetworkError

public enum NetworkError: Error, Sendable, Equatable, Hashable {
  case unknown
  case badURL(URL, String)
  case badURLComponents(URLComponents)
  case invalidSession
  case invalidResponse
  case lostInternetConnection
  case decodingFailed(modeType: String, context: String)
  case error(Int?, String?)

  // MARK: Public

  public var errorCode: Int {
    switch self {
    case .unknown: return -101
    case .badURL: return -102
    case .badURLComponents: return -103
    case .invalidSession: return -104
    case .invalidResponse: return -105
    case .lostInternetConnection: return -106
    case .decodingFailed: return -107
    case let .error(code, _): return code ?? -108
    }
  }

  public var localizedDescription: String {
    switch self {
    case .unknown: return "Unknown issue"
    case let .badURL(url, path): return "Bad URL base: \(url) path: \(path)"
    case let .badURLComponents(components): return "Bad URL components: \(components)"
    case .invalidSession: return "Invalid session"
    case .invalidResponse: return "Invalid response"
    case .lostInternetConnection: return "The network connection was lost"
    case let .decodingFailed(modeType, context):
      return "\(modeType) decoding failed error: \(context)"
    case let .error(_, msg): return msg ?? "Network error with code: \(errorCode)"
    }
  }
}
