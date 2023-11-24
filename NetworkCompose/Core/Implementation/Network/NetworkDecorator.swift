//
//  NetworkDecorator.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

/// A final class designed for automation testing purposes, implementing the `NetworkInterface`.
/// It is intended for use in scenarios where network behavior needs to be customized or controlled
/// for testing purposes, leveraging the capabilities provided by automation handling.
final class NetworkDecorator<SessionType: NetworkSession>: NetworkInterface {
    /// The dispatch queue for observing and handling network events.
    private let observeQueue: NetworkDispatchQueue

    /// The handler responsible for managing automation expectations.
    private lazy var automationHandler: NetworkAutomationHandler = .init()

    /// Initializes the `NetworkDecorator` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests. Default is `URLSession.shared`.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    ///   - expectations: An array of automation expectations with predefined responses.
    init(baseURL _: URL,
         session _: SessionType = URLSession.shared,
         executeQueue _: NetworkDispatchQueue,
         observeQueue: NetworkDispatchQueue,
         expectations: [NetworkExpectation])
    {
        self.observeQueue = observeQueue
        automationHandler.addExpectations(expectations)
    }

    /// Asynchronously sends a network request and returns the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - retryPolicy: The retry policy for the network request.
    /// - Returns: A task representing the asynchronous operation.
    /// - Throws: An error if the network request fails.
    @available(iOS 15.0, *)
    func request<RequestType>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        retryPolicy _: NetworkRetryPolicy = .none
    ) async throws -> RequestType.SuccessType where RequestType: NetworkRequestInterface {
        do {
            let result = try requestMockResponse(request)
            return result
        } catch {
            throw error
        }
    }

    /// Sends a network request and executes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called with the result.
    func request<RequestType>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        retryPolicy _: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        requestMockResponse(request, completion: completion)
    }

    /// Uploads a file using a network request and executes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - fileURL: The URL of the file to be uploaded.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called with the result.
    func uploadFile<RequestType>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        fromFile _: URL,
        retryPolicy _: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        requestMockResponse(request, completion: completion)
    }

    /// Downloads a file using a network request and executes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be performed.
    ///   - headers: Additional headers to be included in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called with the result.
    func downloadFile<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        retryPolicy _: NetworkRetryPolicy = .none,
        completion: @escaping (Result<URL, NetworkError>) -> Void
    ) {
        downloadMockResponse(request, completion: completion)
    }
}

extension NetworkDecorator {
    /// Get a mocked response for a network request.
    ///
    /// - Parameter request: The network request for which to get a mocked response.
    /// - Returns: The mocked response.
    ///
    /// - Throws: A `NetworkError` if there is an issue retrieving the mocked response.
    @available(iOS 15.0, *)
    func requestMockResponse<RequestType>(
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: NetworkRequestInterface {
        return try automationHandler.getRequestResponse(request)
    }

    /// Asynchronously retrieves a mocked response for a network request and executes a completion handler.
    ///
    /// - Parameters:
    ///   - request: The network request for which to get a mocked response.
    ///   - completion: The completion handler to be called with the result.
    ///
    /// - Note: The completion handler is executed on the observation queue.
    func requestMockResponse<RequestType>(
        _ request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        do {
            let result = try automationHandler.getRequestResponse(request)
            observeQueue.async {
                completion(.success(result))
            }
        } catch {
            observeQueue.async {
                let networkError = NetworkError.networkError(nil, error.localizedDescription)
                completion(.failure(networkError))
            }
        }
    }

    /// Asynchronously retrieves a mocked download response for a network request and executes a completion handler.
    ///
    /// - Parameters:
    ///   - request: The network request for which to get a mocked download response.
    ///   - completion: The completion handler to be called with the result.
    ///
    /// - Note: The completion handler is executed on the observation queue.
    func downloadMockResponse<RequestType>(
        _ request: RequestType,
        completion: @escaping (Result<URL, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        do {
            let result = try automationHandler.getDownloadResponse(request)
            observeQueue.async {
                completion(.success(result))
            }
        } catch {
            observeQueue.async {
                let networkError = NetworkError.networkError(nil, error.localizedDescription)
                completion(.failure(networkError))
            }
        }
    }
}
