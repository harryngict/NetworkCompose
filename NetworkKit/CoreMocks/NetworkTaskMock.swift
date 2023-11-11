//
//  NetworkTaskMock.swift
//  CoreMocks
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

public class NetworkTaskMock<T: Decodable>: NetworkTask {
    private var expected: NetworkKitResultMock

    public init(expected: NetworkKitResultMock) {
        self.expected = expected
    }

    public func data(
        _: NetworkRequestMock<T>,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) {
        switch expected {
        case let .failure(error): completion(.failure(error))
        case let .requestSuccess(response): completion(.success(response))
        default: break
        }
    }
}
