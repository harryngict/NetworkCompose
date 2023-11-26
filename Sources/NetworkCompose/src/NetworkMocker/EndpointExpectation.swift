//
//  EndpointExpectation.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

public struct EndpointExpectation {
    public let name: String
    public let path: String
    public let method: NetworkMethod
    public let response: Response

    public enum Response {
        case failure(NetworkError)
        case successResponse(Decodable)
    }

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

    public func isSameRequest<RequestType>(
        _ request: RequestType
    ) -> Bool where RequestType: NetworkRequestInterface {
        return path == request.path && method == request.method
    }

    public func getResponse<RequestType>(
        _: RequestType
    ) throws -> RequestType.SuccessType where RequestType: NetworkRequestInterface {
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
    public static func == (lhs: EndpointExpectation, rhs: EndpointExpectation) -> Bool {
        return lhs.name == rhs.name && lhs.path == rhs.path && lhs.method == rhs.method
    }
}
