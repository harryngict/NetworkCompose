//
//  StorageServiceProvider.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 26/11/23.
//

import Foundation

final class StorageServiceProvider: StorageService {
    private let storageService: StorageService

    init(loggerInterface: LoggerInterface?,
         executeQueue: DispatchQueueType)
    {
        storageService = FileSystemStorageService(loggerInterface: loggerInterface,
                                                  executeQueue: executeQueue)
    }

    func storeResponse<RequestType>(
        _ request: RequestType,
        data: Data,
        model: RequestType.SuccessType
    ) throws where RequestType: RequestInterface {
        try storageService.storeResponse(request, data: data, model: model)
    }

    func getResponse<RequestType>(
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: RequestInterface {
        try storageService.getResponse(request)
    }

    func clearMockDataInDisk() throws {
        try storageService.clearMockDataInDisk()
    }
}
