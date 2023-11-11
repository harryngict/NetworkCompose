//
//  NetworkKit.swift
//  Core/Interfaces
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

/// @mockable
public protocol NetworkKit: AnyObject {
    @available(iOS 15.0, *)
    func request<RequestType: NetworkRequest>(
        _ request: RequestType
    ) async throws -> RequestType.SuccessType

    func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    )

    func uploadFile<RequestType: NetworkRequest>(
        _ request: RequestType,
        fromFile fileURL: URL,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    )

    func downloadFile<RequestType: NetworkRequest>(
        _ request: RequestType,
        completion: @escaping (Result<URL, NetworkError>) -> Void
    )
}
