//
//  NetworkError.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 11/11/23.
//

import Foundation

public enum NetworkError: Error, Sendable, Equatable, Hashable {
    case unknown
    case badURL(URL, String)
    case badURLComponents(URLComponents)
    case invalidSession
    case invalidResponse
    case downloadResponseTempURLNil
    case lostInternetConnection
    case decodingFailed(modeType: String, context: String)
    case authenticationError
    case error(Int?, String?)
    case automation(AutomationError) // Support for automation testing

    public var errorCode: Int {
        switch self {
        case .unknown: return -101
        case .badURL: return -102
        case .badURLComponents: return -103
        case .invalidSession: return -104
        case .invalidResponse: return -105
        case .downloadResponseTempURLNil: return -106
        case .lostInternetConnection: return -107
        case .decodingFailed: return -108
        case .authenticationError: return -109
        case let .error(code, _): return code ?? -110
        case let .automation(error): return error.errorCode
        }
    }

    public var localizedDescription: String {
        switch self {
        case .unknown: return "Unknown issue"
        case let .badURL(url, path): return "Bad URL base: \(url) path: \(path)"
        case let .badURLComponents(components): return "Bad URL components: \(components)"
        case .invalidSession: return "Invalid session"
        case .invalidResponse: return "Invalid response"
        case .downloadResponseTempURLNil: return "Download response temp url is nil"
        case .lostInternetConnection: return "The network connection was lost"
        case let .decodingFailed(modeType, context):
            return "\(modeType) decoding failed error: \(context)"
        case .authenticationError: return "Authentication error occurred"
        case let .automation(error): return error.localizedDescription
        case let .error(_, msg): return msg ?? "Network error with code: \(errorCode)"
        }
    }
}

public enum AutomationError: Error, Sendable, Equatable, Hashable {
    case requestNotSameAsExepectation(method: String, path: String)
    case responseTypeNotSameAsExpectation(modeType: String)
    case notFoundHomeDirectory
    case storageServiceNonExist

    public var errorCode: Int {
        switch self {
        case .requestNotSameAsExepectation: return -301
        case .responseTypeNotSameAsExpectation: return -302
        case .notFoundHomeDirectory: return -303
        case .storageServiceNonExist: return -304
        }
    }

    public var localizedDescription: String {
        switch self {
        case let .requestNotSameAsExepectation(method, path):
            return "Aumation: The request is not same with expectation. Please check: \(method) \(path)"
        case let .responseTypeNotSameAsExpectation(modeType):
            return "Automation: The reponse is not same with expectation. Please check: \(modeType)"
        case .notFoundHomeDirectory:
            return "Automation: we do not find the home directory data for automation testing"
        case .storageServiceNonExist:
            return "Automation: Storage service non exist for automation testing"
        }
    }
}
