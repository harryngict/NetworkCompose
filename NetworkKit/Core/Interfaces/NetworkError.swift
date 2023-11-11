//
//  NetworkError.swift
//  Core/Interfaces
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public enum NetworkError: Error {
    case badURL(URL, String)
    case badURLComponents(URLComponents)
    case invalidDecodeReponse(type: Decodable.Type)
    case invalidSession
    case invalidResponse
    case serviceError(Int?, String?)

    public var errorCode: Int {
        switch self {
        case .badURL: return -101
        case .badURLComponents: return -102
        case .invalidDecodeReponse: return -103
        case .invalidSession: return -104
        case .invalidResponse: return -105
        case let .serviceError(code, _): return code != nil ? code! : -106
        }
    }

    public var localizedDescription: String {
        switch self {
        case let .badURL(url, path): return "Bad URL: \(url) \(path)"
        case let .badURLComponents(components): return "Bad URL components: \(components)"
        case let .invalidDecodeReponse(type): return "Invalid decode response model: \(type)"
        case .invalidSession: return "Invalid session"
        case .invalidResponse: return "Invalid response"
        case let .serviceError(_, msg): return msg != nil ? msg! : "Service error with code: \(errorCode)"
        }
    }
}
