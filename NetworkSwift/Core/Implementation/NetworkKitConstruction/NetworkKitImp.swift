//
//  NetworkKitImp.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

/// A class implementing the `NetworkKit` protocol that handles network requests.
///
/// Example usage:
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let networkKit = NetworkKitImp(baseURL: baseURL)
/// ```
public final class NetworkKitImp<SessionType: NetworkSession>: NetworkKit {
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

    /// Initializes the `NetworkKitImp` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests. Default is `URLSession.shared`.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    public init(baseURL: URL,
                session: SessionType = URLSession.shared,
                networkReachability: NetworkReachability = NetworkReachabilityImp.shared,
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

    /// Deinitializes the `NetworkKitImp` and stops monitoring network reachability.
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
    public func request<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none
    ) async throws -> RequestType.SuccessType where RequestType: NetworkRequest {
        debugPrint(request.debugDescription)

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
    public func request<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequest {
        debugPrint(request.debugDescription)

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
                                self.executeQueue.async {
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
    public func uploadFile<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        fromFile fileURL: URL,
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequest {
        debugPrint(request.debugDescription)

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
                                self.executeQueue.async {
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
    public func downloadFile<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<URL, NetworkError>) -> Void
    ) {
        debugPrint(request.debugDescription)

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
                            self.executeQueue.async {
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

    private func buildNetworkRequest<RequestType: NetworkRequest>(
        for request: RequestType,
        andHeaders headers: [String: String]
    ) throws -> SessionType.NetworkRequestType {
        return try session.build(request, withBaseURL: baseURL, andHeaders: headers)
    }

    private func handleSuccessResponse<RequestType: NetworkRequest>(
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
    ) where RequestType: NetworkRequest {
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
