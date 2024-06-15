//
//  StorageServiceInterface.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 26/11/23.
//

import Foundation
import NetworkCompose

/// @mockable
protocol StorageServiceInterface: AnyObject {
  /// Stores the response data for a given request.
  ///
  /// - Parameters:
  ///   - request: The request for which the response is being stored.
  ///   - data: The data representing the response.
  ///   - model: The model representing the successful response type.
  /// - Throws: An error if storing the response fails.
  /// - SeeAlso: `RequestInterface`
  func storeResponse<RequestType>(_ request: RequestType,
                                  data: Data,
                                  model: RequestType.SuccessType) throws where RequestType: RequestInterface

  /// Retrieves the stored response for a given request.
  ///
  /// - Parameter request: The request for which to retrieve the response.
  /// - Returns: The successful response type corresponding to the request.
  /// - Throws: An error if retrieving the response fails.
  /// - SeeAlso: `RequestInterface`
  func getResponse<RequestType>(
    _ request: RequestType
  ) throws -> RequestType.SuccessType where RequestType: RequestInterface

  /// Clears all mock data stored on disk.
  ///
  /// - Throws: An error if clearing mock data fails.
  func clearMockDataInDisk() throws
}
