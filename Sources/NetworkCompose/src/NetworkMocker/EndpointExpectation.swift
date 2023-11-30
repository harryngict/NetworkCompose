//
//  EndpointExpectation.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

public struct EndpointExpectation {
    public let uniqueKey: UniqueKey
    public let response: Response

    /// The possible responses for the network request.
    public enum Response {
        /// Represents a failure response with a specific network error.
        case failure(NetworkError)

        /// Represents a success response with a decodable result.
        case successResponse(Decodable)
    }

    /// Initializes an `EndpointExpectation` instance with the specified components.
    ///
    /// - Parameters:
    ///   - path: The path of the network request.
    ///   - method: The HTTP method of the network request.
    ///   - queryParameters: Optional query parameters for the network request. Default is `nil`.
    ///   - response: The expected response for the network request.
    public init(path: String,
                method: NetworkMethod,
                queryParameters: [String: Any]? = nil,
                response: Response)
    {
        uniqueKey = UniqueKey(path: path,
                              method: method,
                              queryParameters: queryParameters)
        self.response = response
    }

    /// Compares the current expectation with a given network request to check if they represent the same request.
    ///
    /// - Parameter request: The network request to compare.
    /// - Returns: `true` if the requests are the same; otherwise, `false`.
    public func isSameRequest<RequestType>(
        _ request: RequestType
    ) -> Bool where RequestType: RequestInterface {
        let identifier = UniqueKey(request: request)
        return uniqueKey.key == identifier.key
    }

    /// Retrieves the expected success response for a given network request.
    ///
    /// - Parameter request: The network request for which the response is expected.
    /// - Returns: The expected success response.
    /// - Throws: An error if the response type is not the same as the expected success type.
    public func getResponse<RequestType>(
        _: RequestType
    ) throws -> RequestType.SuccessType where RequestType: RequestInterface {
        switch response {
        case let .failure(error):
            throw error
        case let .successResponse(response):
            guard let response = response as? RequestType.SuccessType else {
                throw NetworkError.automation(.responseTypeNotSameAsExpectation(modeType: String(describing: RequestType.SuccessType.self)))
            }
            return response
        }
    }
}

extension EndpointExpectation: Equatable {
    /// Checks if two `EndpointExpectation` instances are equal by comparing their unique keys.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `EndpointExpectation`.
    ///   - rhs: The right-hand side `EndpointExpectation`.
    /// - Returns: `true` if the unique keys are equal; otherwise, `false`.
    public static func == (lhs: EndpointExpectation, rhs: EndpointExpectation) -> Bool {
        return lhs.uniqueKey == rhs.uniqueKey
    }
}
