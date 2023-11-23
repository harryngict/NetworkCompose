//
//  NetworkRequest.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

/// Protocol for defining network requests.
public protocol NetworkRequest {
    /// Endpoint path for the request.
    var path: String { get }

    /// HTTP method for the request (GET, POST, etc.).
    var method: NetworkMethod { get }

    /// Query parameters to be included in the request URL.
    var queryParameters: [String: Any]? { get }

    /// Headers to be included in the request.
    var headers: [String: String] { get }

    /// Encoding type for the request body.
    var bodyEncoding: BodyEncoding { get }

    /// Timeout interval for the request.
    var timeoutInterval: TimeInterval { get }

    /// Cache policy for the request.
    var cachePolicy: NetworkCachePolicy { get }

    /// Decoder for decoding the response.
    var responseDecoder: ResponseDecoder { get }

    /// Indicates whether re-authentication is required for the request.
    var requiresReAuthentication: Bool { get }

    /// Associated type representing the expected success response type.
    associatedtype SuccessType: Decodable
}

/// Default implementations for the NetworkRequest protocol.
public extension NetworkRequest {
    /// Indicates whether re-authentication is required for the request.
    var requiresReAuthentication: Bool { return false }

    /// A textual representation of the request.
    var description: String {
        let parameters = queryParameters?.urlEncodedQueryString() ?? ""
        return "\(method) \(path)\(parameters.isEmpty ? "" : "?")\(parameters)"
    }

    /// A detailed textual representation of the request for debugging.
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

        // Append bodyDescription only if it is not empty
        if !bodyDescription.isEmpty {
            return string + "  " + bodyDescription
        }

        return string
    }

    /// Cache policy for the URLRequest.
    ///
    /// This property provides the corresponding URLRequest.CachePolicy
    /// based on the specified NetworkCachePolicy.
    var cacheURLRequestPolicy: URLRequest.CachePolicy {
        switch cachePolicy {
        case .remote: return .useProtocolCachePolicy
        case .cacheData: return .returnCacheDataElseLoad
        case .ignoreCache: return .reloadIgnoringLocalCacheData
        }
    }

    /// Optional body data for the request.
    ///
    /// If the HTTP method allows a request body, this property provides the data to be included in
    /// the request body. The inclusion depends on the result of the `shouldIncludeBody` method.
    ///
    /// For example, if the HTTP method is GET, the request body is not included, and this property
    /// returns `nil`. For methods like POST and PUT, the request body is included based on the encoding
    /// type specified by the `bodyEncoding` property.
    ///
    /// - Returns: The optional data to be included in the request body, or `nil` if the body should
    ///            not be included.
    var body: Data? {
        guard shouldIncludeBody() else {
            return nil
        }
        switch bodyEncoding {
        case .json: return encodeToJSON()
        case .url: return encodeToURLEncoded()
        }
    }

    /// Generates the headers for a network request, combining the base headers with additional headers.
    ///
    /// The base headers are determined by the request's body encoding. If the body encoding is JSON,
    /// the Content-Type header is set to "application/json; charset=UTF-8". If the body encoding is URL,
    /// the Content-Type header is set to "application/x-www-form-urlencoded; charset=utf-8".
    ///
    /// - Parameter additionalHeaders: Additional headers to include in the request.
    /// - Returns: The combined headers for the network request.
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

    /// Query items to be included in the request URL.
    var queryItems: [URLQueryItem]? {
        return shouldIncludeBody() ? nil : generateQueryItems()
    }

    /// Generate query items from the queryParameters.
    private func generateQueryItems() -> [URLQueryItem]? {
        return queryParameters?.compactMap { key, value in
            guard !String(describing: value).isEmpty else { return nil }
            return URLQueryItem(name: key, value: String(describing: value))
        }
    }

    /// Determines whether the request should include a body based on the HTTP method.
    ///
    /// For HTTP methods like GET, the request does not include a body. For methods like POST, PUT,
    /// DELETE, HEAD, and PATCH, the request includes a body.
    ///
    /// - Returns: `true` if the request should include a body, `false` otherwise.
    private func shouldIncludeBody() -> Bool {
        switch method {
        case .GET:
            return false
        case .POST, .PUT, .DELETE, .HEAD, .PATCH:
            return true
        }
    }
}

/// Extends the `NetworkRequest` protocol with a default implementation for the body property.
private extension NetworkRequest {
    /// Helper method to encode the request parameters to JSON.
    ///
    /// This method converts the request parameters into JSON data.
    ///
    /// - Returns: JSON-encoded data or nil if encoding fails.
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

    /// Helper method to encode the request parameters to URL-encoded format.
    ///
    /// This method converts the request parameters into a URL-encoded query string.
    ///
    /// - Returns: URL-encoded data or nil if encoding fails.
    func encodeToURLEncoded() -> Data? {
        guard let parameters = queryParameters else {
            return nil
        }
        let queryString = parameters.urlEncodedQueryString()
        return queryString.data(using: .utf8)
    }
}

/// Enumeration to represent different HTTP methods.
public enum NetworkMethod: String, Sendable {
    case GET, POST, PUT, DELETE, HEAD, PATCH
}

/// Enumeration to represent different network cache policies.
public enum NetworkCachePolicy: Sendable {
    case remote, ignoreCache, cacheData
}

/// Enumeration to represent different encoding types for the request body.
public enum BodyEncoding: Sendable {
    case json
    case url
}
