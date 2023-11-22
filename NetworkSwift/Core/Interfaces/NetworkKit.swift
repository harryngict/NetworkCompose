//
//  NetworkKit.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

/// A protocol representing the network communication interface.
public protocol NetworkKit: AnyObject {
    /// Asynchronously sends a network request and returns the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - retryPolicy: The retry policy for the network request.
    /// - Returns: A task representing the asynchronous operation.
    /// - Throws: An error if the network request fails.
    @available(iOS 15.0, *)
    func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: NetworkRetryPolicy
    ) async throws -> RequestType.SuccessType

    /// Sends a network request and executes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called with the result.
    func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    )

    /// Uploads a file using a network request and executes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - fileURL: The URL of the file to be uploaded.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called with the result.
    func uploadFile<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        fromFile fileURL: URL,
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    )

    /// Downloads a file using a network request and executes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called with the result.
    func downloadFile<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<URL, NetworkError>) -> Void
    )
}
