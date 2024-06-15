//
//  NetworkSessionExecutor.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 11/11/23.
//

import Foundation

// MARK: - NetworkSessionExecutor

public protocol NetworkSessionExecutor: AnyObject {
  /// Sends a network request and executes the completion handler with the result.
  ///
  /// - Parameters:
  ///   - request: The network request to be performed.
  ///   - headers: Additional headers to be included in the request.
  ///   - retryPolicy: The retry policy for the network request.
  ///   - completion: The completion handler to be called with the result.
  ///
  /// - Note: Use this method for non-async network requests or when compatibility with earlier iOS versions is required.
  func request<RequestType>(_ request: RequestType,
                            andHeaders headers: [String: String],
                            retryPolicy: RetryPolicy,
                            completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) where RequestType: RequestInterface

  /// Cancels an ongoing network request. Cancellation may not be immediate; handle the result in the original request's completion block.
  ///
  /// - Parameters:
  ///   - request: The request conforming to `RequestInterface` to be canceled.
  ///
  /// - Important: Ensure the passed request matches the one used for the network request. Cancellation effectiveness depends on underlying network session support.
  func cancelRequest<RequestType>(
    _ request: RequestType
  ) where RequestType: RequestInterface
}

/// An extension providing default implementations for methods of the `NetworkSessionExecutor` protocol.
public extension NetworkSessionExecutor {
  /// Sends a network request and executes the completion handler with the result, using default parameter values.
  ///
  /// - Parameters:
  ///   - request: The network request to be performed.
  ///   - headers: Additional headers to be included in the request.
  ///   - retryPolicy: The retry policy for the network request.
  ///   - completion: The completion handler to be called with the result.
  func request<RequestType>(_ request: RequestType,
                            andHeaders headers: [String: String] = [:],
                            retryPolicy: RetryPolicy = .disabled,
                            completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) where RequestType: RequestInterface
  {
    self.request(
      request,
      andHeaders: headers,
      retryPolicy: retryPolicy,
      completion: completion)
  }
}
