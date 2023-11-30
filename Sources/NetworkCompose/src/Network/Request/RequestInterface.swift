//
//  RequestInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public protocol RequestInterface {
    /// The path of the request URL.
    var path: String { get }

    /// The  method for the request.
    var method: NetworkMethod { get }

    /// The query parameters to be included in the request URL, if any.
    var queryParameters: [String: Any]? { get }

    /// The headers to be included in the request.
    var headers: [String: String] { get }

    /// The body encoding method for the request.
    var bodyEncoding: BodyEncoding { get }

    /// The timeout interval for the request.
    var timeoutInterval: TimeInterval { get }

    /// The cache policy for the request.
    var cachePolicy: NetworkCachePolicy { get }

    /// The response decoder used to decode the response data.
    var responseDecoder: ResponseDecoder { get }

    /// A Boolean value indicating whether the request requires re-authentication.
    var requiresReAuthentication: Bool { get }

    /// The type of the expected success response, conforming to `Decodable`.
    associatedtype SuccessType: Decodable
}

public extension RequestInterface {
    var queryParameters: [String: Any]? { return nil }
    var headers: [String: String] { return [:] }
    var bodyEncoding: BodyEncoding { return .json }
    var timeoutInterval: TimeInterval { return 60.0 }
    var cachePolicy: NetworkCachePolicy { return .ignoreCache }
    var responseDecoder: ResponseDecoder { return JSONDecoder() }
    var requiresReAuthentication: Bool { return false }

    var description: String {
        let parameters = queryParameters?.urlEncodedQueryString() ?? ""
        return "\(method) \(path)\(parameters.isEmpty ? "" : "?")\(parameters)"
    }

    var debugDescription: String {
        let string = description
        var bodyDescription = ""

        if let body = body {
            switch bodyEncoding {
            case .json:
                if let data = try? JSONEncoder().encode(body),
                   let bodyString = String(data: data, encoding: .utf8)
                {
                    bodyDescription = "[Body-JSON]: \(bodyString)"
                }
            case .url:
                if let bodyString = String(data: body, encoding: .utf8) {
                    bodyDescription = "[Body-URL Encoded]: \(bodyString)"
                }
            }
        }

        if !bodyDescription.isEmpty {
            return string + "  " + bodyDescription
        }

        return string
    }

    var cacheURLRequestPolicy: URLRequest.CachePolicy {
        switch cachePolicy {
        case .remote: return .useProtocolCachePolicy
        case .cacheData: return .returnCacheDataElseLoad
        case .ignoreCache: return .reloadIgnoringLocalCacheData
        }
    }

    var body: Data? {
        guard shouldIncludeBody() else {
            return nil
        }
        switch bodyEncoding {
        case .json: return encodeToJSON()
        case .url: return encodeToURLEncoded()
        }
    }

    func generateRequestHeaders(with additionalHeaders: [String: String]) -> [String: String] {
        var baseHeaders: [String: String] = [:]

        if shouldIncludeBody() {
            switch bodyEncoding {
            case .json:
                baseHeaders["Content-Type"] = "application/json; charset=UTF-8"
            case .url:
                baseHeaders["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
            }
        }
        return baseHeaders.merging(headers, uniquingKeysWith: { $1 }).merging(additionalHeaders, uniquingKeysWith: { $1 })
    }

    var queryItems: [URLQueryItem]? {
        return shouldIncludeBody() ? nil : generateQueryItems()
    }

    private func generateQueryItems() -> [URLQueryItem]? {
        return queryParameters?.compactMap { key, value in
            guard !String(describing: value).isEmpty else { return nil }
            return URLQueryItem(name: key, value: String(describing: value))
        }
    }

    private func shouldIncludeBody() -> Bool {
        switch method {
        case .GET:
            return false
        case .POST, .PUT, .DELETE, .HEAD, .PATCH:
            return true
        }
    }
}

private extension RequestInterface {
    func encodeToJSON() -> Data? {
        guard let parameters = queryParameters else {
            return nil
        }
        do {
            return try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            return nil
        }
    }

    func encodeToURLEncoded() -> Data? {
        guard let parameters = queryParameters else {
            return nil
        }
        let queryString = parameters.urlEncodedQueryString()
        return queryString.data(using: .utf8)
    }
}

public enum NetworkMethod: String, Sendable {
    case GET, POST, PUT, DELETE, HEAD, PATCH
}

public enum NetworkCachePolicy: Sendable {
    case remote, ignoreCache, cacheData
}

public enum BodyEncoding: Sendable {
    case json
    case url
}
