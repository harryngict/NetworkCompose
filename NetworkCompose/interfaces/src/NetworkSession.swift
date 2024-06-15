//
//  NetworkSession.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 11/11/23.
//

import Foundation

/// @mockable
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
}
