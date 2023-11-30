//
//  NetworkRouter.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

final class NetworkRouter<SessionType: NetworkSession>: NetworkRouterInterface {
    /// The HTTP status code indicating unauthorized access.
    private let unauthorizedErrorCode = 401

    /// A flag indicating whether the router is currently re-authenticating.
    private var isReAuthenticating = false

    /// An array to store closures representing pending requests with new headers.
    private var pendingRequests: [(Result<[String: String], NetworkError>) -> Void] = []

    /// The underlying network session executor responsible for handling network requests.
    private let network: NetworkSessionExecutorInteface

    /// The logger interface for logging network events.
    private var loggerInterface: LoggerInterface?

    /// The service responsible for re-authentication.
    public var reAuthService: ReAuthenticationService?

    /// Initializes the `NetworkRouter` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    ///   - reAuthService: The service responsible for re-authentication.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executionQueue: The dispatch queue for executing network requests.
    ///   - observationQueue: The dispatch queue for observing and handling network events.
    ///   - storageService: The service for handling storage-related tasks.
    ///   - loggerInterface: The interface for logging network events.
    init(
        baseURL: URL,
        session: SessionType,
        reAuthService: ReAuthenticationService? = nil,
        networkReachability: NetworkReachabilityInterface,
        executionQueue: DispatchQueueType,
        observationQueue: DispatchQueueType,
        storageService: StorageServiceInterface?,
        loggerInterface: LoggerInterface? = nil
    ) {
        self.reAuthService = reAuthService
        self.loggerInterface = loggerInterface
        network = NetworkSessionExecutor(baseURL: baseURL,
                                         session: session,
                                         networkReachability: networkReachability,
                                         executionQueue: executionQueue,
                                         observationQueue: observationQueue,
                                         storageService: storageService,
                                         loggerInterface: loggerInterface)
    }

    /// Performs a network request.
    ///
    /// - Parameters:
    ///   - request: The request to be performed.
    ///   - headers: Additional headers for the request.
    ///   - retryPolicy: The retry policy for handling request failures.
    ///   - completion: A closure called when the request is completed.
    func request<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: RetryPolicy = .disabled,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        executeOperation(request,
                         headers: headers,
                         allowReAuth: request.requiresReAuthentication,
                         retryPolicy: retryPolicy,
                         completion: completion)
        {
            self.network.request($0,
                                 andHeaders: $1,
                                 retryPolicy: $2,
                                 completion: $3)
        }
    }

    /// Uploads a file as part of a network request.
    ///
    /// - Parameters:
    ///   - request: The request to be performed.
    ///   - headers: Additional headers for the request.
    ///   - fileURL: The URL of the file to be uploaded.
    ///   - retryPolicy: The retry policy for handling request failures.
    ///   - completion: A closure called when the upload is completed.
    func upload<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        fromFile fileURL: URL,
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        executeOperation(request,
                         headers: headers,
                         allowReAuth: request.requiresReAuthentication,
                         retryPolicy: retryPolicy,
                         completion: completion)
        {
            self.network.upload($0,
                                andHeaders: $1,
                                fromFile: fileURL,
                                retryPolicy: $2,
                                completion: $3)
        }
    }

    /// Downloads a resource from the network.
    ///
    /// - Parameters:
    ///   - request: The request to be performed.
    ///   - headers: Additional headers for the request.
    ///   - retryPolicy: The retry policy for handling request failures.
    ///   - completion: A closure called when the download is completed.
    func download<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        executeOperation(request,
                         headers: headers,
                         allowReAuth: request.requiresReAuthentication,
                         retryPolicy: retryPolicy,
                         completion: completion)
        {
            self.network.download($0,
                                  andHeaders: $1,
                                  retryPolicy: $2,
                                  completion: $3)
        }
    }

    /// Cancels a network request.
    ///
    /// - Parameter request: The request to be canceled.
    func cancelRequest<RequestType>(
        _ request: RequestType
    ) where RequestType: RequestInterface {
        network.cancelRequest(request)
    }
}

// MARK: Helper method

private extension NetworkRouter {
    func executeOperation<RequestType>(
        _ request: RequestType,
        headers: [String: String],
        allowReAuth: Bool,
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void,
        operation: @escaping (RequestType,
                              [String: String],
                              RetryPolicy,
                              @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) -> Void
    ) where RequestType: RequestInterface {
        if isReAuthenticating && allowReAuth {
            pendingRequests.append { [weak self] reAuthenResult in

                switch reAuthenResult {
                case let .success(newHeaders):
                    self?.executeOperation(request,
                                           headers: newHeaders,
                                           allowReAuth: false,
                                           retryPolicy: retryPolicy,
                                           completion: completion,
                                           operation: operation)
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        } else {
            operation(request, headers, retryPolicy) { [weak self] result in
                switch result {
                case let .success(model):
                    completion(.success(model))
                case let .failure(error):
                    if error.errorCode == self?.unauthorizedErrorCode, allowReAuth {
                        self?.handleUnauthorizedError(request)
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    func handleUnauthorizedError<RequestType>(
        _ request: RequestType
    ) where RequestType: RequestInterface {
        isReAuthenticating = true
        loggerInterface?.log(.debug, "Token expired at request: \(request.debugDescription)")

        guard let reAuthService = reAuthService else {
            completePendingRequests(result: .failure(NetworkError.authenticationError))
            return
        }

        reAuthService.reAuthen { [weak self] reAuthResult in
            switch reAuthResult {
            case let .success(newHeaders):
                self?.completePendingRequests(result: .success(newHeaders))
            case let .failure(error):
                self?.completePendingRequests(result: .failure(error))
            }
        }
    }

    func completePendingRequests(result: Result<[String: String], NetworkError>) {
        isReAuthenticating = false
        pendingRequests.forEach { $0(result) }
        pendingRequests.removeAll()
    }
}
