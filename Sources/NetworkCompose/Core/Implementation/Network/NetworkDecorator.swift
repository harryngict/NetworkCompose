//
//  NetworkDecorator.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

final class NetworkDecorator<SessionType: NetworkSession>: NetworkInterface {
    private let observeQueue: NetworkDispatchQueue
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

    func request<RequestType>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        retryPolicy _: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        requestMockResponse(request, completion: completion)
    }

    func uploadFile<RequestType>(
        _ request: RequestType,
        andHeaders _: [String: String] = [:],
        fromFile _: URL,
        retryPolicy _: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        requestMockResponse(request, completion: completion)
    }

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
