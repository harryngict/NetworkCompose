//
//  NetworkRouter.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

/// A concrete implementation of the `NetworkRouterInterface` protocol.
///
/// This class coordinates network operations, including requests, uploads, and downloads.
/// It handles re-authentication if necessary and utilizes an operation queue for serialization.
final class NetworkRouter<SessionType: NetworkSession>: NetworkRouterInterface {
    private let unauthorizedErrorCode = 401
    private let network: NetworkSessionExecutorInteface
    private var loggerInterface: LoggerInterface?
    public var reAuthService: ReAuthenticationService?

    /// Initializes the `NetworkQueue` with the specified configuration.
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
        reAuthService: ReAuthenticationService?,
        networkReachability: NetworkReachabilityInterface,
        executionQueue: DispatchQueueType,
        observationQueue: DispatchQueueType,
        storageService: StorageService?,
        loggerInterface: LoggerInterface?
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

    func request<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: RetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        logRequest(request, .startRequest)
        executeRequest(request,
                       headers: headers,
                       allowReAuth: request.requiresReAuthentication,
                       retryPolicy: retryPolicy,
                       completion: completion)
    }

    func upload<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        fromFile fileURL: URL,
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        logRequest(request, .startRequest)
        executeUpload(request,
                      headers: headers,
                      fromFile: fileURL,
                      allowReAuth: request.requiresReAuthentication,
                      retryPolicy: retryPolicy,
                      completion: completion)
    }

    func download<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        logRequest(request, .startRequest)
        executeDownload(request,
                        headers: headers,
                        allowReAuth: request.requiresReAuthentication,
                        retryPolicy: retryPolicy,
                        completion: completion)
    }

    private enum RequestLogCase {
        case startRequest
        case requestAutheticationExpired
    }

    private func logRequest<RequestType>(
        _ request: RequestType,
        _ logCase: RequestLogCase
    ) where RequestType: RequestInterface {
        switch logCase {
        case .startRequest:
            loggerInterface?.log(.debug, request.debugDescription)
        case .requestAutheticationExpired:
            loggerInterface?.log(.debug, "Token expired for request: \(request.debugDescription), Authentication action is triggered")
        }
    }

    func cancelRequest<RequestType>(
        _ request: RequestType
    ) where RequestType: RequestInterface {
        network.cancelRequest(request)
    }
}

extension NetworkRouter {
    private func executeRequest<RequestType>(
        _ request: RequestType,
        headers: [String: String],
        allowReAuth: Bool,
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        network.request(request, andHeaders: headers, retryPolicy: retryPolicy) { [weak self] result in
            switch result {
            case let .success(model):
                completion(.success(model))
            case let .failure(error):
                if error.errorCode == self?.unauthorizedErrorCode, allowReAuth, let reAuthService = self?.reAuthService {
                    self?.logRequest(request, .requestAutheticationExpired)
                    reAuthService.reAuthen { reAuthResult in
                        switch reAuthResult {
                        case let .success(newHeaders):
                            self?.executeRequest(request,
                                                 headers: newHeaders,
                                                 allowReAuth: false,
                                                 retryPolicy: retryPolicy,
                                                 completion: completion)
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    private func executeUpload<RequestType>(
        _ request: RequestType,
        headers: [String: String],
        fromFile fileURL: URL,
        allowReAuth: Bool,
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        network.upload(request, andHeaders: headers, fromFile: fileURL, retryPolicy: retryPolicy) { [weak self] result in
            switch result {
            case let .success(model):
                completion(.success(model))
            case let .failure(error):
                if error.errorCode == self?.unauthorizedErrorCode, allowReAuth, let reAuthService = self?.reAuthService {
                    self?.logRequest(request, .requestAutheticationExpired)
                    reAuthService.reAuthen { reAuthResult in
                        switch reAuthResult {
                        case let .success(newHeaders):
                            self?.executeUpload(request,
                                                headers: newHeaders,
                                                fromFile: fileURL,
                                                allowReAuth: false,
                                                retryPolicy: retryPolicy,
                                                completion: completion)
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    private func executeDownload<RequestType>(
        _ request: RequestType,
        headers: [String: String],
        allowReAuth: Bool,
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        network.download(request, andHeaders: headers, retryPolicy: retryPolicy) { [weak self] result in
            switch result {
            case let .success(model):
                completion(.success(model))
            case let .failure(error):
                if error.errorCode == self?.unauthorizedErrorCode, allowReAuth, let reAuthService = self?.reAuthService {
                    self?.logRequest(request, .requestAutheticationExpired)
                    reAuthService.reAuthen { reAuthResult in
                        switch reAuthResult {
                        case let .success(newHeaders):
                            self?.executeDownload(request,
                                                  headers: newHeaders,
                                                  allowReAuth: false,
                                                  retryPolicy: retryPolicy,
                                                  completion: completion)
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
}
