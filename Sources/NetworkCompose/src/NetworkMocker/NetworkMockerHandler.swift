//
//  NetworkMockerHandler.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

final class NetworkMockerHandler {
    private let mockerStrategy: MockerStrategy
    private var storageService: StorageService?

    init(_ mockerStrategy: MockerStrategy, executeQueue _: NetworkDispatchQueue) {
        self.mockerStrategy = mockerStrategy
        if case let .localStorage(strategy) = mockerStrategy {
            storageService = StorageServiceProvider(strategy)
        }
    }

    func getRequestResponse<RequestType>(
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: NetworkRequestInterface {
        switch mockerStrategy {
        case let .custom(provider):
            guard let expectation = provider.expectations.first(where: { $0.isSameRequest(request) }) else {
                throw NetworkError.automation(.requestNotSameAsExepectation(method: request.method.rawValue,
                                                                            path: request.path))
            }
            return try expectation.getResponse(request)
        case .localStorage:
            guard let storageService else {
                throw NetworkError.automation(.storageServiceNonExist)
            }
            return try storageService.getResponse(request)
        }
    }
}
