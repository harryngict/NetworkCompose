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
    case automation(AutomationError) // FOR AUTOMATION TESTING
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
        case let .automation(error): return error.errorCode
        case let .error(code, _): return code ?? -112
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
