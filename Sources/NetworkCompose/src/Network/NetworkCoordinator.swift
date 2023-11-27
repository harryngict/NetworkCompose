//
//  NetworkCoordinator.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

/// A protocol representing a network coordinator with additional authentication features.
/// Inherits from `NetworkControllerInterface` and includes a property for re-authentication service.
public protocol NetworkCoordinatorInterface: NetworkControllerInterface {
    /// An optional re-authentication service that can be used for refreshing authentication tokens.
    var reAuthService: ReAuthenticationService? { get }
}

final class NetworkCoordinator<SessionType: NetworkSession>: NetworkCoordinatorInterface {
    private let networkCore: NetworkControllerInterface
    private let operationQueue: OperationQueueManagerInterface
    private var loggerInterface: LoggerInterface?
    public var reAuthService: ReAuthenticationService?

    /// Initializes the `NetworkQueue` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    ///   - reAuthService: The service responsible for re-authentication.
    ///   - operationQueue: The operation queue manager for serializing network operations. Default is `serialOperationQueue`.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    ///   - storageService: The service for handling storage-related tasks.
    ///   - loggerInterface: The interface for logging network events.
    init(
        baseURL: URL,
        session: SessionType,
        reAuthService: ReAuthenticationService?,
        operationQueue: OperationQueueManagerInterface,
        networkReachability: NetworkReachabilityInterface,
        executeQueue: DispatchQueueType,
        observeQueue: DispatchQueueType,
        storageService: StorageService?,
        loggerInterface: LoggerInterface?
    ) {
        self.reAuthService = reAuthService
        self.operationQueue = operationQueue
        self.loggerInterface = loggerInterface
        networkCore = NetworkController(baseURL: baseURL,
                                        session: session,
                                        networkReachability: networkReachability,
                                        executeQueue: executeQueue,
                                        observeQueue: observeQueue,
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
        guard request.requiresReAuthentication else {
            sendRequest(request,
                        andHeaders: headers,
                        allowReAuth: false,
                        retryPolicy: retryPolicy,
                        completion: completion)
            return
        }
        let operation = createRequestOperation(request,
                                               andHeaders: headers,
                                               retryPolicy: retryPolicy,
                                               completion: completion)
        operationQueue.enqueue(operation)
    }

    func upload<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        fromFile fileURL: URL,
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        logRequest(request, .startRequest)
        guard request.requiresReAuthentication else {
            sendUploadRequest(request,
                              andHeaders: headers,
                              fromFile: fileURL,
                              allowReAuth: false,
                              retryPolicy: retryPolicy,
                              completion: completion)
            return
        }
        let operation = createUploadOperation(request,
                                              andHeaders: headers,
                                              fromFile: fileURL,
                                              retryPolicy: retryPolicy,
                                              completion: completion)
        operationQueue.enqueue(operation)
    }

    func download<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        logRequest(request, .startRequest)
        guard request.requiresReAuthentication else {
            sendDownloadRequest(request,
                                andHeaders: headers,
                                allowReAuth: false,
                                retryPolicy: retryPolicy,
                                completion: completion)
            return
        }
        let operation = createDownloadOperation(request,
                                                andHeaders: headers,
                                                retryPolicy: retryPolicy,
                                                completion: completion)
        operationQueue.enqueue(operation)
    }

    private func cancelAllOperations() {
        guard let operations = operationQueue.operationQueue.operations as? [ClosureCustomOperation] else {
            return
        }
        for operation in operations {
            operation.validOperation = false
        }
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
            loggerInterface?
                .log(.debug, "Token is expred for request: \(request.debugDescription), Authenticaiton action is triggered")
        }
    }
}

// MARK: Request execution

extension NetworkCoordinator {
    private func createRequestOperation<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) -> CustomOperation where RequestType: RequestInterface {
        let asyncOperation = ClosureCustomOperation { operation in
            operation.state = .executing
            self.sendRequest(request, andHeaders: headers,
                             allowReAuth: request.requiresReAuthentication,
                             retryPolicy: retryPolicy)
            { result in
                switch result {
                case let .success(model): completion(.success(model))
                case let .failure(error): completion(.failure(error))
                }
                operation.state = .finished
            }
        }

        return asyncOperation
    }

    private func sendRequest<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        allowReAuth: Bool,
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        networkCore.request(request, andHeaders: headers, retryPolicy: retryPolicy) { [weak self] result in
            switch result {
            case let .success(model):
                completion(.success(model))
            case let .failure(error):
                if error.errorCode == 401, allowReAuth, let reAuthService = self?.reAuthService {
                    self?.logRequest(request, .requestAutheticationExpired)
                    reAuthService.reAuthen { reAuthResult in
                        switch reAuthResult {
                        case let .success(newHeaders):
                            self?.sendRequest(request, andHeaders: newHeaders, allowReAuth: false,
                                              retryPolicy: retryPolicy,
                                              completion: completion)
                        case let .failure(error):
                            self?.cancelAllOperations()
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

// MARK: Upload execution

extension NetworkCoordinator {
    private func createUploadOperation<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        fromFile fileURL: URL,
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) -> CustomOperation where RequestType: RequestInterface {
        let asyncOperation = ClosureCustomOperation { operation in
            operation.state = .executing
            self.sendUploadRequest(request,
                                   andHeaders: headers,
                                   fromFile: fileURL,
                                   allowReAuth: request.requiresReAuthentication,
                                   retryPolicy: retryPolicy)
            { result in
                switch result {
                case let .success(model): completion(.success(model))
                case let .failure(error): completion(.failure(error))
                }
                operation.state = .finished
            }
        }

        return asyncOperation
    }

    private func sendUploadRequest<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        fromFile fileURL: URL,
        allowReAuth: Bool,
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        networkCore.upload(request,
                           andHeaders: headers,
                           fromFile: fileURL,
                           retryPolicy: retryPolicy)
        { [weak self] result in
            switch result {
            case let .success(model):
                completion(.success(model))
            case let .failure(error):
                if error.errorCode == 401, allowReAuth, let reAuthService = self?.reAuthService {
                    self?.logRequest(request, .requestAutheticationExpired)
                    reAuthService.reAuthen { reAuthResult in
                        switch reAuthResult {
                        case let .success(newHeaders):
                            self?.sendUploadRequest(request,
                                                    andHeaders: newHeaders,
                                                    fromFile: fileURL,
                                                    allowReAuth: false,
                                                    retryPolicy: retryPolicy,
                                                    completion: completion)
                        case let .failure(error):
                            self?.cancelAllOperations()
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

// MARK: Download execution

extension NetworkCoordinator {
    private func createDownloadOperation<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) -> CustomOperation where RequestType: RequestInterface {
        let asyncOperation = ClosureCustomOperation { operation in
            operation.state = .executing
            self.sendDownloadRequest(request, andHeaders: headers,
                                     allowReAuth: request.requiresReAuthentication,
                                     retryPolicy: retryPolicy)
            { result in
                switch result {
                case let .success(model): completion(.success(model))
                case let .failure(error): completion(.failure(error))
                }
                operation.state = .finished
            }
        }

        return asyncOperation
    }

    private func sendDownloadRequest<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        allowReAuth: Bool,
        retryPolicy: RetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: RequestInterface {
        networkCore.download(request, andHeaders: headers, retryPolicy: retryPolicy) { [weak self] result in
            switch result {
            case let .success(model):
                completion(.success(model))
            case let .failure(error):
                if error.errorCode == 401, allowReAuth, let reAuthService = self?.reAuthService {
                    self?.logRequest(request, .requestAutheticationExpired)
                    reAuthService.reAuthen { reAuthResult in
                        switch reAuthResult {
                        case let .success(newHeaders):
                            self?.sendDownloadRequest(request, andHeaders: newHeaders, allowReAuth: false,
                                                      retryPolicy: retryPolicy,
                                                      completion: completion)
                        case let .failure(error):
                            self?.cancelAllOperations()
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
