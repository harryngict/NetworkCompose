//
//  NetworkMockHandler.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

final class NetworkMockHandler {
    private let dataType: AutomationMode.DataType
    private let executionQueue: DispatchQueueType
    private var loggerInterface: LoggerInterface?

    init(_ dataType: AutomationMode.DataType,
         loggerInterface _: LoggerInterface?,
         executionQueue: DispatchQueueType)
    {
        self.dataType = dataType
        self.executionQueue = executionQueue
    }

    func getRequestResponse<RequestType>(
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: RequestInterface {
        switch dataType {
        case let .custom(provider):
            return try handleCustomProvider(provider, request: request)

        case .local:
            guard let storageService = getStorageService(dataType) else {
                throw NetworkError.automation(.storageServiceNonExist)
            }
            return try storageService.getResponse(request)
        }
    }
}

private extension NetworkMockHandler {
    func handleCustomProvider<RequestType>(
        _ provider: EndpointExpectationProvider,
        request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: RequestInterface {
        let expectation = provider.expectation(for: request.path,
                                               method: request.method,
                                               queryParameters: request.queryParameters)

        guard expectation.isSameRequest(request) else {
            throw NetworkError.automation(.requestNotSameAsExepectation(method: request.method.rawValue,
                                                                        path: request.path))
        }
        return try expectation.getResponse(request)
    }

    func getStorageService(
        _ dataType: AutomationMode.DataType
    ) -> StorageServiceInterface? {
        switch dataType {
        case .local:
            return StorageServiceDecorator(loggerInterface: loggerInterface,
                                           executionQueue: executionQueue)
        default:
            return nil
        }
    }
}
