//
//  NetworkSessionExecutorInteface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public protocol NetworkSessionExecutorInteface: AnyObject {
    /// Sends a network request and executes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called with the result.
    ///
    /// - Note: Use this method for non-async network requests or when compatibility with earlier iOS versions is required.
    func request<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface

    /// Uploads a file using a network request and executes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - fileURL: The URL of the file to be uploaded.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called with the result.
    func upload<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        fromFile fileURL: URL,
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface

    /// Downloads a file using a network request and executes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called with the result.
    func download<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface

    /// Cancels an ongoing network request.
    ///
    /// - Parameters:
    ///   - request: The request object conforming to `RequestInterface` representing the network operation to be canceled.
    ///
    /// - Important: The cancellation may not take immediate effect. Handle the result appropriately in the original request's completion block.
    ///
    /// Example: `networkSessionExecutor.cancelRequest(myRequest)`
    ///
    /// - Note: Ensure the request object passed matches the one used to initiate the network request. Cancellation effectiveness depends on underlying network session support.
    func cancelRequest<RequestType>(
        _ request: RequestType
    ) where RequestType: RequestInterface
}

/// An extension providing default implementations for methods of the `NetworkSessionExecutorInteface` protocol.
public extension NetworkSessionExecutorInteface {
    /// Sends a network request and executes the completion handler with the result, using default parameter values.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called with the result.
    func request<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: RetryPolicy = .disabled,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        self.request(request,
                     andHeaders: headers,
                     retryPolicy: retryPolicy,
                     completion: completion)
    }

    /// Uploads a file using a network request and executes the completion handler with the result, using default parameter values.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - fileURL: The URL of the file to be uploaded.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called with the result.
    func upload<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        fromFile fileURL: URL,
        retryPolicy: RetryPolicy = .disabled,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        upload(request,
               andHeaders: headers,
               fromFile: fileURL,
               retryPolicy: retryPolicy,
               completion: completion)
    }

    /// Downloads a file using a network request and executes the completion handler with the result, using default parameter values.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called with the result.
    func download<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: RetryPolicy = .disabled,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        download(request,
                 andHeaders: headers,
                 retryPolicy: retryPolicy,
                 completion: completion)
    }
}
