//
//  NetworkKitQueue.swift
//  NetworkSwift/Queue
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

/// A protocol for managing network requests within a queue, providing support for authentication services and asynchronous request handling.
public protocol NetworkKitQueue: AnyObject {
    // MARK: - Properties

    /// An optional reauthentication service for handling reauthentication challenges.
    var reAuthService: ReAuthenticationService? { get }

    // MARK: - Request Handling

    /// Handles a network request.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to be included in the request.
    ///   - completion: A closure to be executed upon completion of the request.
    func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    )
}
