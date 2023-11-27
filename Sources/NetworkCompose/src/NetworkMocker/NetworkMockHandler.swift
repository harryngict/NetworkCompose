//
//  NetworkMockHandler.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

final class NetworkMockHandler {
    private let mockerStrategy: MockerStrategy
    private var storageService: StorageService?

    init(_ mockerStrategy: MockerStrategy, executeQueue _: DispatchQueueType) {
        self.mockerStrategy = mockerStrategy
        if case let .localStorage(strategy) = mockerStrategy {
            storageService = StorageServiceProvider(strategy)
        }
    }

    func getRequestResponse<RequestType>(
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: RequestInterface {
        switch mockerStrategy {
        case let .custom(provider):
            let clientExpection = provider.getExpectaion(path: request.path, method: request.method)
            guard clientExpection.isSameRequest(request) else {
                throw NetworkError.automation(.requestNotSameAsExepectation(method: request.method.rawValue,
                                                                            path: request.path))
            }
            return try clientExpection.getResponse(request)
        case .localStorage:
            guard let storageService else {
                throw NetworkError.automation(.storageServiceNonExist)
            }
            return try storageService.getResponse(request)
        }
    }
}
