//
//  NetworkSession.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public protocol NetworkSession: AnyObject {
    /// Associated type representing the network request type.
    associatedtype SessionRequest

    /// Builds a network request based on the provided parameters.
    /// - Parameters:
    ///   - request: The network request to be built.
    ///   - baseURL: The base URL for the request.
    ///   - headers: Additional headers to be included in the request.
    /// - Returns: The built network request.
    func build<RequestType>(
        _ request: RequestType,
        withBaseURL baseURL: URL,
        andHeaders headers: [String: String]
    ) throws -> SessionRequest where RequestType: RequestInterface

    /// Performs a network request and executes the completion handler with the result.
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - completion: The completion handler to be called with the result.
    /// - Returns: A task representing the asynchronous operation.
    @discardableResult
    func beginRequest(
        _ request: SessionRequest,
        completion: @escaping ((Result<ResponseInterface, NetworkError>) -> Void)
    ) -> NetworkTask

    /// Uploads a file using a network request and executes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The `NetworkRequestType` representing the network request to be performed. It should be configured with the necessary details for the upload.
    ///   - fromFile: The URL of the file to be uploaded.
    ///   - completion: The completion handler to be called with the result. The closure takes a `Result` enum with either a `NetworkResponse` on success or a `NetworkError` on failure.
    ///
    /// - Returns: A `NetworkTask` representing the asynchronous operation. Use this task to manage or cancel the upload.
    /// - Throws: A `NetworkError` if there is an issue with the network request or file upload.
    @discardableResult
    func beginUploadTask(
        _ request: inout SessionRequest,
        fromFile: URL,
        completion: @escaping ((Result<ResponseInterface, NetworkError>) -> Void)
    ) throws -> NetworkTask

    /// Downloads a file using a network request and executes the completion handler with the result.
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - completion: The completion handler to be called with the result.
    /// - Returns: A task representing the asynchronous operation.
    @discardableResult
    func beginDownloadTask(
        _ request: SessionRequest,
        completion: @escaping ((Result<ResponseInterface, NetworkError>) -> Void)
    ) -> NetworkTask
}
