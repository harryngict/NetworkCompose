//
//  StorageServiceDecorator.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 26/11/23.
//

import Foundation
import NetworkCompose

final class StorageServiceDecorator: StorageServiceInterface {
  // MARK: Lifecycle

  init(loggerInterface: LoggerInterface?,
       executionQueue: DispatchQueueType)
  {
    self.loggerInterface = loggerInterface
    storageService = FileSystemStorageService(executionQueue: executionQueue)
  }

  // MARK: Internal

  func storeResponse<RequestType>(_ request: RequestType,
                                  data: Data,
                                  model: RequestType.SuccessType) throws where RequestType: RequestInterface
  {
    try storageService.storeResponse(
      request,
      data: data,
      model: model)
  }

  func getResponse<RequestType>(
    _ request: RequestType
  ) throws -> RequestType.SuccessType where RequestType: RequestInterface {
    try storageService.getResponse(request)
  }

  func clearMockDataInDisk() throws {
    try storageService.clearMockDataInDisk()
  }

  // MARK: Private

  private let storageService: StorageServiceInterface
  private var loggerInterface: LoggerInterface?
}
