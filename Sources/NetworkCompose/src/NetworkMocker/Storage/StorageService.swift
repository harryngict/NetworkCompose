//
//  StorageService.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 26/11/23.
//

import Foundation

protocol StorageService: AnyObject {
    func storeResponse<RequestType>(
        _ request: RequestType,
        data: Data,
        model: RequestType.SuccessType
    ) throws where RequestType: RequestInterface

    func getResponse<RequestType>(
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: RequestInterface

    func clearMockDataInDisk() throws
}
