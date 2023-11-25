//
//  NetworkExpectation.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

public struct NetworkExpectation {
    public let name: String
    public let path: String
    public let method: NetworkMethod
    public let response: Response

    public enum Response {
        case failure(NetworkError)
        case successResponse(Codable)
        case downLoadSuccessResponse(URL)
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
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: NetworkRequestInterface {
        guard isSameRequest(request) else {
            throw NetworkError.notSameExpectedRequest(method: request.method.rawValue, path: request.path)
        }
        switch response {
        case let .failure(error):
            throw error
        case let .successResponse(response):
            guard let response = response as? RequestType.SuccessType else {
                throw NetworkError.decodingFailed(modeType: String(describing: RequestType.SuccessType.self),
                                                  context: "typeMismatch")
            }
            return response
        case .downLoadSuccessResponse:
            throw NetworkError.decodingFailed(modeType: String(describing: RequestType.SuccessType.self),
                                              context: "typeMismatch to downLoadSuccessResponse")
        }
    }

    public func getDownloadResponse<RequestType>(
        _ request: RequestType
    ) throws -> URL where RequestType: NetworkRequestInterface {
        guard isSameRequest(request) else {
            throw NetworkError.notSameExpectedRequest(method: request.method.rawValue, path: request.path)
        }
        switch response {
        case let .failure(error):
            throw error
        case .successResponse:
            throw NetworkError.decodingFailed(modeType: String(describing: RequestType.SuccessType.self),
                                              context: "typeMismatch to successResponse")
        case let .downLoadSuccessResponse(url):
            return url
        }
    }
}

extension NetworkExpectation: Equatable {
    public static func == (lhs: NetworkExpectation, rhs: NetworkExpectation) -> Bool {
        return lhs.name == rhs.name && lhs.path == rhs.path && lhs.method == rhs.method
    }
}
