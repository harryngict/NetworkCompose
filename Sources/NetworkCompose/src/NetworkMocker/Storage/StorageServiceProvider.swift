//
//  StorageServiceProvider.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 26/11/23.
//

import Foundation

final class StorageServiceProvider: StorageService {
    private let storageService: StorageService

    init(_ strategy: StorageStrategy) {
        switch strategy {
        case .fileSystem: storageService = FileSystemStorageService()
        case .userDefault: storageService = UserDefaultStorageService()
        }
    }

    func storeResponse<RequestType>(
        _ request: RequestType,
        data: Data,
        model: RequestType.SuccessType
    ) throws where RequestType: NetworkRequestInterface {
        try storageService.storeResponse(request, data: data, model: model)
    }

    func getResponse<RequestType>(
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: NetworkRequestInterface {
        try storageService.getResponse(request)
    }
}
