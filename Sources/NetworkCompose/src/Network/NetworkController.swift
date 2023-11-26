//
//  NetworkController.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

final class NetworkController<SessionType: NetworkSession>: NetworkControllerInterface {
    private let session: SessionType
    private let baseURL: URL
    public let networkReachability: NetworkReachability
    private let executeQueue: DispatchQueueType
    private let observeQueue: DispatchQueueType
    private var storageService: StorageService?

    /// Initializes the `Network` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    ///   - networkReachability: The network reachability object.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    ///   - storageService: An optional storage service for handling persistent data.
    init(baseURL: URL,
         session: SessionType,
         networkReachability: NetworkReachability,
         executeQueue: DispatchQueueType,
         observeQueue: DispatchQueueType,
         storageService: StorageService?)
    {
        self.baseURL = baseURL
        self.session = session
        self.networkReachability = networkReachability
        self.executeQueue = executeQueue
        self.observeQueue = observeQueue
        self.storageService = storageService
        self.networkReachability.startMonitoring(completion: { _ in })
    }

    func request<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        guard networkReachability.isInternetAvailable else {
            observeQueue.async {
                completion(.failure(NetworkError.lostInternetConnection))
            }
            return
        }
        var currentRetry = 0

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
                            self.retryIfNeeded(currentRetry: currentRetry,
                                               retryPolicy: retryPolicy,
                                               error: error,
                                               performRequest: performRequest,
                                               completion: completion)
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

    func upload<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        fromFile fileURL: URL,
        retryPolicy: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        guard networkReachability.isInternetAvailable else {
            observeQueue.async {
                completion(.failure(NetworkError.lostInternetConnection))
            }
            return
        }
        var currentRetry = 0

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
                            self.retryIfNeeded(currentRetry: currentRetry,
                                               retryPolicy: retryPolicy,
                                               error: error,
                                               performRequest: performRequest,
                                               completion: completion)
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

    func download<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequestInterface {
        guard networkReachability.isInternetAvailable else {
            observeQueue.async {
                completion(.failure(NetworkError.lostInternetConnection))
            }
            return
        }
        var currentRetry = 0

        func performRequest() {
            do {
                let networkRequest = try buildNetworkRequest(for: request, andHeaders: headers)
                session.beginDownloadTask(networkRequest) { result in
                    self.handleResult(result, for: request) { result in
                        switch result {
                        case let .success(model):
                            self.observeQueue.async {
                                completion(.success(model))
                            }
                        case let .failure(error):
                            currentRetry += 1
                            self.retryIfNeeded(currentRetry: currentRetry,
                                               retryPolicy: retryPolicy,
                                               error: error,
                                               performRequest: performRequest,
                                               completion: completion)
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
            throw NetworkError.error(response.statusCode, nil)
        }
        let model = try request.responseDecoder.decode(RequestType.SuccessType.self, from: response.data)

        /// Store object for automation testing.
        if let storageService = storageService {
            try storageService.storeResponse(request,
                                             data: response.data,
                                             model: model)
        }
        return model
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
                } else if let decodingError = error as? DecodingError {
                    completion(.failure(NetworkError.decodingFailed(modeType: String(describing: RequestType.SuccessType.self),
                                                                    context: decodingError.localizedDescription)))
                } else {
                    completion(.failure(NetworkError.error(nil, error.localizedDescription)))
                }
            }
        case let .failure(error):
            completion(.failure(error))
        }
    }

    private func retryIfNeeded<SuccessType>(
        currentRetry: Int,
        retryPolicy: RetryPolicy,
        error: NetworkError,
        performRequest: @escaping () -> Void,
        completion: @escaping (Result<SuccessType, NetworkError>) -> Void
    ) where SuccessType: Decodable {
        let shouldRetry = retryPolicy.shouldRetry(currentRetry: currentRetry)
        if shouldRetry {
            let delay = retryPolicy.retryDelay(currentRetry: currentRetry) ?? 0
            executeQueue.asyncAfter(deadline: .now() + delay) {
                performRequest()
            }
        } else {
            observeQueue.async {
                completion(.failure(error))
            }
        }
    }
}
