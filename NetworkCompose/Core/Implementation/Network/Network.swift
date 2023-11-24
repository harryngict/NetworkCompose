//
//  Network.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

/// A class implementing the `NetworkInterface` protocol that handles network requests.
///
final class Network<SessionType: NetworkSession>: NetworkInterface {
    /// The network session used for making requests.
    private let session: SessionType

    /// The base URL for network requests.
    private let baseURL: URL

    /// The network reachability object for monitoring internet connection status.
    public let networkReachability: NetworkReachability

    /// The dispatch queue for executing network requests.
    private let executeQueue: NetworkDispatchQueue

    /// The dispatch queue for observing and handling network events.
    private let observeQueue: NetworkDispatchQueue

    /// Initializes the `Network` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    ///   - networkReachability: The network reachability object.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    init(baseURL: URL,
         session: SessionType,
         networkReachability: NetworkReachability,
         executeQueue: NetworkDispatchQueue,
         observeQueue: NetworkDispatchQueue)
    {
        self.baseURL = baseURL
        self.session = session
        self.networkReachability = networkReachability
        self.executeQueue = executeQueue
        self.observeQueue = observeQueue
        self.networkReachability.startMonitoring(completion: { _ in })
    }

    /// Deinitializes the `Network` and stops monitoring network reachability.
    deinit {
        self.networkReachability.stopMonitoring()
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
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none
    ) async throws -> RequestType.SuccessType where RequestType: NetworkRequestInterface {
        guard networkReachability.isInternetAvailable else {
            throw NetworkError.lostInternetConnection
        }
        var currentRetry = 0

        /// Asynchronously performs the network request.
        func performRequest() async throws -> RequestType.SuccessType {
            do {
                let networkRequest = try buildNetworkRequest(for: request, andHeaders: headers)
                let response = try await session.beginRequest(networkRequest)
                return try handleSuccessResponse(response, for: request)
            } catch {
                currentRetry += 1
                let shouldRetry = retryPolicy.shouldRetry(currentRetry: currentRetry)
                if shouldRetry {
                    if let delay = retryPolicy.retryDelay(currentRetry: currentRetry) {
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000)) // Convert seconds to nanoseconds
                    }
                    return try await performRequest()
                } else {
                    throw error
                }
            }
        }

        return try await performRequest()
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
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        guard networkReachability.isInternetAvailable else {
            observeQueue.async {
                completion(.failure(NetworkError.lostInternetConnection))
            }
            return
        }
        var currentRetry = 0

        /// Performs the network request with a completion handler.
        func performRequest() {
            do {
                let networkRequest = try buildNetworkRequest(for: request, andHeaders: headers)
                session.beginRequest(networkRequest) { result in
                    self.handleResult(result, for: request) { result in
                        switch result {
                        case let .success(model):
                            self.observeQueue.async {
                                completion(.success(model))
                            }
                        case let .failure(error):
                            currentRetry += 1
                            let shouldRetry = retryPolicy.shouldRetry(currentRetry: currentRetry)
                            if shouldRetry {
                                let delay = retryPolicy.retryDelay(currentRetry: currentRetry) ?? 0
                                self.executeQueue.asyncAfter(deadline: .now() + delay) {
                                    performRequest()
                                }
                            } else {
                                self.observeQueue.async {
                                    completion(.failure(error))
                                }
                            }
                        }
                    }
                }
            } catch {
                observeQueue.async {
                    completion(.failure(NetworkError.invalidSession))
                }
            }
        }
        executeQueue.async {
            performRequest()
        }
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
        andHeaders headers: [String: String] = [:],
        fromFile fileURL: URL,
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        guard networkReachability.isInternetAvailable else {
            observeQueue.async {
                completion(.failure(NetworkError.lostInternetConnection))
            }
            return
        }
        var currentRetry = 0

        /// Performs the network request to upload a file.
        func performRequest() {
            do {
                var networkRequest = try buildNetworkRequest(for: request, andHeaders: headers)
                try session.beginUploadTask(&networkRequest, fromFile: fileURL) { result in
                    self.handleResult(result, for: request) { result in
                        switch result {
                        case let .success(model):
                            self.observeQueue.async {
                                completion(.success(model))
                            }
                        case let .failure(error):
                            currentRetry += 1
                            let shouldRetry = retryPolicy.shouldRetry(currentRetry: currentRetry)
                            if shouldRetry {
                                let delay = retryPolicy.retryDelay(currentRetry: currentRetry) ?? 0
                                self.executeQueue.asyncAfter(deadline: .now() + delay) {
                                    performRequest()
                                }
                            } else {
                                self.observeQueue.async {
                                    completion(.failure(error))
                                }
                            }
                        }
                    }
                }
            } catch {
                observeQueue.async {
                    completion(.failure(NetworkError.invalidSession))
                }
            }
        }

        executeQueue.async {
            performRequest()
        }
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
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<URL, NetworkError>) -> Void
    ) {
        guard networkReachability.isInternetAvailable else {
            observeQueue.async {
                completion(.failure(NetworkError.lostInternetConnection))
            }
            return
        }
        var currentRetry = 0

        /// Performs the network request to download a file.
        func performRequest() {
            do {
                let networkRequest = try buildNetworkRequest(for: request, andHeaders: headers)
                session.beginDownloadTask(networkRequest) { result in
                    switch result {
                    case let .success(url):
                        self.observeQueue.async {
                            completion(.success(url))
                        }
                    case let .failure(error):
                        currentRetry += 1
                        let shouldRetry = retryPolicy.shouldRetry(currentRetry: currentRetry)
                        if shouldRetry {
                            let delay = retryPolicy.retryDelay(currentRetry: currentRetry) ?? 0
                            self.executeQueue.asyncAfter(deadline: .now() + delay) {
                                performRequest()
                            }
                        } else {
                            self.observeQueue.async {
                                completion(.failure(error))
                            }
                        }
                    }
                }
            } catch {
                observeQueue.async {
                    completion(.failure(NetworkError.invalidSession))
                }
            }
        }

        executeQueue.async {
            performRequest()
        }
    }

    private func buildNetworkRequest<RequestType: NetworkRequestInterface>(
        for request: RequestType,
        andHeaders headers: [String: String]
    ) throws -> SessionType.NetworkRequestType {
        return try session.build(request, withBaseURL: baseURL, andHeaders: headers)
    }

    private func handleSuccessResponse<RequestType: NetworkRequestInterface>(
        _ response: NetworkResponse,
        for request: RequestType
    ) throws -> RequestType.SuccessType {
        guard (200 ... 299).contains(response.statusCode) else {
            throw NetworkError.networkError(response.statusCode, nil)
        }
        return try request.responseDecoder.decode(RequestType.SuccessType.self, from: response.data)
    }

    private func handleResult<RequestType>(
        _ result: Result<NetworkResponse, NetworkError>,
        for request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        switch result {
        case let .success(response):
            do {
                let decodedResponse = try handleSuccessResponse(response, for: request)
                completion(.success(decodedResponse))
            } catch {
                if let error = error as? NetworkError {
                    completion(.failure(error))

                } else {
                    completion(.failure(NetworkError.networkError(nil, error.localizedDescription)))
                }
            }
        case let .failure(error):
            completion(.failure(error))
        }
    }
}
