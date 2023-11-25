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
    case downloadResponseTempURLNil
    case lostInternetConnection
    case decodingFailed(modeType: String, context: String)
    case notSameExpectedRequest(method: String, path: String) // for automation testing
    case error(Int?, String?)

    public var errorCode: Int {
        switch self {
        case .badURL: return -101
        case .badURLComponents: return -102
        case .invalidSession: return -103
        case .invalidResponse: return -104
        case .downloadResponseTempURLNil: return -105
        case .lostInternetConnection: return -106
        case .decodingFailed: return -107
        case .notSameExpectedRequest: return -108
        case let .error(code, _): return code ?? -109
        }
    }

    public var localizedDescription: String {
        switch self {
        case let .badURL(url, path): return "Bad URL base: \(url) path: \(path)"
        case let .badURLComponents(components): return "Bad URL components: \(components)"
        case .invalidSession: return "Invalid session"
        case .invalidResponse: return "Invalid response"
        case .downloadResponseTempURLNil: return "Download response temp url is nill"
        case .lostInternetConnection: return "The network connection was lost"
        case let .decodingFailed(modeType, context):
            return "\(modeType) decoding failed error: \(context)"
        case let .notSameExpectedRequest(method, path):
            return "The request is not same with expectation. Please check: \(method) \(path)"
        case let .error(_, msg): return msg ?? "Network error with code: \(errorCode)"
        }
    }
}
