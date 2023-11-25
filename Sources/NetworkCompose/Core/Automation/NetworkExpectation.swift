//
//  NetworkExpectation.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

/// A struct representing an expectation with a predefined response for network requests.
public struct NetworkExpectation {
    /// The name of the expectation.
    public let name: String

    /// The path for which the expectation is defined.
    public let path: String

    /// The HTTP method for which the expectation is defined.
    public let method: NetworkMethod

    /// The predefined response associated with the expectation.
    public let response: Response

    /// Enum representing different types of responses for the expectation.
    public enum Response {
        case failure(NetworkError)
        case successResponse(Codable)
        case downLoadSuccessResponse(URL)
    }

    /// Initializes an `ExpectationWithResponse` instance.
    ///
    /// - Parameters:
    ///   - name: The name of the expectation.
    ///   - path: The path for which the expectation is defined.
    ///   - method: The HTTP method for which the expectation is defined.
    ///   - response: The predefined response associated with the expectation.
    public init(name: String,
                path: String,
                method: NetworkMethod,
                response: Response)
    {
        self.name = name
        self.path = path
        self.method = method
        self.response = response
    }

    /// Checks if the expectation is for the same network request as the provided `NetworkRequestInterface`.
    ///
    /// - Parameter request: The network request to compare against.
    /// - Returns: `true` if the expectation is for the same request; otherwise, `false`.
    public func isSameRequest<RequestType>(
        _ request: RequestType
    ) -> Bool where RequestType: NetworkRequestInterface {
        return path == request.path && method == request.method
    }

    /// Retrieves the predefined success response for the expectation.
    ///
    /// - Parameter request: The network request to retrieve the response for.
    /// - Returns: The success response if available.
    /// - Throws: A `NetworkError` if the expectation is not for the same request or if the response type is invalid.
    public func getResponse<RequestType>(
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: NetworkRequestInterface {
        guard isSameRequest(request) else {
            throw NetworkError.invalidResponse
        }
        switch response {
        case let .failure(error):
            throw error
        case let .successResponse(response):
            guard let response = response as? RequestType.SuccessType else {
                throw NetworkError.invalidResponse
            }
            return response
        case .downLoadSuccessResponse:
            throw NetworkError.invalidResponse
        }
    }

    /// Retrieves the predefined download response (URL) for the expectation.
    ///
    /// - Parameter request: The network request to retrieve the download URL for.
    /// - Returns: The download URL if available.
    /// - Throws: A `NetworkError` if the expectation is not for the same request or if the response type is invalid.
    public func getDownloadResponse<RequestType>(
        _ request: RequestType
    ) throws -> URL where RequestType: NetworkRequestInterface {
        guard isSameRequest(request) else {
            throw NetworkError.invalidResponse
        }
        switch response {
        case let .failure(error):
            throw error
        case .successResponse:
            throw NetworkError.invalidResponse
        case let .downLoadSuccessResponse(url):
            return url
        }
    }
}

// MARK: - Equatable

extension NetworkExpectation: Equatable {
    /// Compares two `ExpectationWithResponse` instances for equality.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `NetworkExpectation`.
    ///   - rhs: The right-hand side `NetworkExpectation`.
    /// - Returns: `true` if the instances are equal; otherwise, `false`.
    public static func == (lhs: NetworkExpectation, rhs: NetworkExpectation) -> Bool {
        return lhs.name == rhs.name && lhs.path == rhs.path && lhs.method == rhs.method
    }
}
