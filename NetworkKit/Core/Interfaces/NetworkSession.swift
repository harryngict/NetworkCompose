//
//  NetworkSession.swift
//  Core/Interfaces
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public protocol NetworkSession: AnyObject {
    associatedtype NetworkRequestType

    func build<RequestType: NetworkRequest>(
        _ request: RequestType,
        withBaseURL: URL,
        withAuthHeaders: [String: String]
    ) throws -> NetworkRequestType

    @available(iOS 15.0, *)
    @discardableResult
    func beginRequest(
        _ request: NetworkRequestType
    ) async throws -> NetworkResponse

    @discardableResult
    func beginRequest(
        _ request: NetworkRequestType,
        completion: @escaping ((Result<NetworkResponse, NetworkError>) -> Void)
    ) -> NetworkTask

    @discardableResult
    func beginUploadTask(
        _ request: NetworkRequestType,
        fromFile: URL,
        completion: @escaping ((Result<NetworkResponse, NetworkError>) -> Void)
    ) -> NetworkTask

    @discardableResult
    func beginDownloadTask(
        _ request: NetworkRequestType,
        completion: @escaping ((Result<URL, NetworkError>) -> Void)
    ) -> NetworkTask
}
