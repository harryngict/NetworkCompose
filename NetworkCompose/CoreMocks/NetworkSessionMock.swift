//
//  NetworkSessionMock.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public final class NetworkSessionMock<T: Decodable>: NetworkSession {
    public typealias NetworkRequestType = NetworkRequestMock<T>

    private var expected: NetworkExpectation.Response

    public init(expected: NetworkExpectation.Response) {
        self.expected = expected
    }

    public func build<RequestType>(
        _ request: RequestType,
        withBaseURL _: URL,
        andHeaders _: [String: String]
    ) throws -> NetworkRequestMock<T> where RequestType: NetworkRequestInterface {
        return NetworkRequestMock(path: request.path,
                                  method: request.method,
                                  queryParameters: request.queryParameters,
                                  headers: request.headers,
                                  requiresReAuthentication: request.requiresReAuthentication)
    }

    @available(iOS 15.0, *)
    @discardableResult
    public func beginRequest(
        _: NetworkRequestType
    ) async throws -> NetworkResponse {
        switch expected {
        case let .failure(error): throw error
        case let .successResponse(response):
            return NetworkResponseMock(response: response)
        default: throw NetworkError.invalidResponse
        }
    }

    @discardableResult
    public func beginRequest(
        _ request: NetworkRequestType,
        completion: @escaping ((Result<NetworkResponse, NetworkError>) -> Void)
    ) -> NetworkTask {
        let task = NetworkTaskMock<T>(expected: expected)
        task.data(request, completion: completion)
        return task
    }

    public func beginUploadTask(
        _ request: inout NetworkRequestMock<T>,
        fromFile _: URL,
        completion: @escaping ((Result<NetworkResponse, NetworkError>) -> Void)
    ) throws -> NetworkTask {
        let task = NetworkUploadTaskMock<T>(expected: expected)
        task.data(request, completion: completion)
        return task
    }

    public func beginDownloadTask(
        _ request: NetworkRequestMock<T>,
        completion: @escaping ((Result<URL, NetworkError>) -> Void)
    ) -> NetworkTask {
        let task = NetworkDownloadTaskMock<T>(expected: expected)
        task.data(request, completion: completion)
        return task
    }
}