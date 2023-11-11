//
//  NetworkRequest.swift
//  Core/Interfaces
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public protocol NetworkRequest {
    var path: String { get }
    var method: NetworkMethod { get }
    var queryParameters: [String: String] { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
    var cachePolicy: NetworkCachePolicy { get }
    var responseDecode: ResponseDecoder { get }
    var requiresCredentials: Bool { get }
    associatedtype SuccessType: Decodable

    var description: String { get }
    var debugDescription: String { get }
}

public extension NetworkRequest {
    var queryParameters: [String: String] { return [:] }
    var body: Data? { return nil }
    var responseDecode: ResponseDecoder { return JSONDecoder() }
    var timeoutInterval: TimeInterval { return 60.0 }
    var requiresCredentials: Bool { return false }
    var cachePolicy: NetworkCachePolicy { return .ignoreLocalCache }

    var description: String {
        let parameters = queryParameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        return "\(method) \(path)\(parameters.isEmpty ? "" : "?")\(parameters)"
    }

    var debugDescription: String {
        var string = description
        if let body = body, let data = try? JSONEncoder().encode(body),
           let bodyString = String(data: data, encoding: .utf8)
        {
            string += "\nbody: \(bodyString)"
        }
        return string
    }
}

public enum NetworkMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

public enum NetworkCachePolicy {
    case remoteData
    case cacheData
    case ignoreLocalCache
}
