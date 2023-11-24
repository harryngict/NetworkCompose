//
//  NetworkQueueInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

/// A protocol for managing network requests within a queue, providing support for authentication services and asynchronous request handling.
public protocol NetworkQueueInterface: AnyObject {
    // MARK: - Properties

    /// An optional reauthentication service for handling reauthentication challenges.
    var reAuthService: ReAuthenticationService? { get }

    // MARK: - Request Handling

    /// Handles a network request.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to be included in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: A closure to be executed upon completion of the request.
    func request<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    )
}

public extension NetworkQueueInterface {
    func request<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        self.request(request,
                     andHeaders: headers,
                     retryPolicy: retryPolicy,
                     completion: completion)
    }
}
