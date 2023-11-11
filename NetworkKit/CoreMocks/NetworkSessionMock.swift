//
//  NetworkSessionMock.swift
//  CoreMocks
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public final class NetworkSessionMock<T: Decodable>: NetworkSession {
    public typealias NetworkRequestType = NetworkRequestMock<T>

    private var expected: NetworkKitResultMock

    public init(expected: NetworkKitResultMock) {
        self.expected = expected
    }

    public func build<RequestType>(
        _ request: RequestType,
        withBaseURL _: URL,
        withAuthHeaders _: [String: String]
    ) throws -> NetworkRequestMock<T> where RequestType: NetworkRequest {
        return NetworkRequestMock(path: request.path,
                                  method: request.method,
                                  queryParameters: request.queryParameters,
                                  headers: request.headers,
                                  requiresCredentials: request.requiresCredentials)
    }

    @available(iOS 15.0, *)
    @discardableResult
    public func beginRequest(
        _: NetworkRequestType
    ) async throws -> NetworkResponse {
        switch expected {
        case let .failure(error): throw error
        case let .requestSuccess(response): return response
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
        _ request: NetworkRequestMock<T>,
        fromFile _: URL,
        completion: @escaping ((Result<NetworkResponse, NetworkError>) -> Void)
    ) -> NetworkTask {
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
