//
//  NetworkDownloadTaskMock.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

public class NetworkDownloadTaskMock<T: Decodable>: NetworkTask {
    private var expected: NetworkExpectation.Response

    public init(expected: NetworkExpectation.Response) {
        self.expected = expected
    }

    public func data(
        _: NetworkRequestMock<T>,
        completion: @escaping (Result<URL, NetworkError>) -> Void
    ) {
        switch expected {
        case let .failure(error): completion(.failure(error))
        case let .downLoadSuccessResponse(url): completion(.success(url))
        default: break
        }
    }
}