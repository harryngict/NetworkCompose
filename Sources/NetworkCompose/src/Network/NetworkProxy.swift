//
//  NetworkProxy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

final class NetworkProxy<SessionType: NetworkSession>: NetworkProxyInterface {
    private let networkCore: NetworkCoreInterface
    private let operationQueue: OperationQueueManager
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
    init(
        baseURL: URL,
        session: SessionType,
        reAuthService: ReAuthenticationService?,
        operationQueue: OperationQueueManager,
        networkReachability: NetworkReachability,
        executeQueue: NetworkDispatchQueue,
        observeQueue: NetworkDispatchQueue
    ) {
        self.reAuthService = reAuthService
        self.operationQueue = operationQueue
        networkCore = NetworkCore(baseURL: baseURL,
                                  session: session,
                                  networkReachability: networkReachability,
                                  executeQueue: executeQueue,
                                  observeQueue: observeQueue)
    }

    func request<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
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

    func upload<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        fromFile fileURL: URL,
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
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

    func download<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
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
}

// MARK: Request execution

extension NetworkProxy {
    private func createRequestOperation<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) -> CustomOperation {
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

    private func sendRequest<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        allowReAuth: Bool,
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        networkCore.request(request, andHeaders: headers, retryPolicy: retryPolicy) { result in
            switch result {
            case let .success(model):
                completion(.success(model))
            case let .failure(error):
                if error.errorCode == 401, allowReAuth, let reAuthService = self.reAuthService {
                    reAuthService.reAuthen { reAuthResult in
                        switch reAuthResult {
                        case let .success(newHeaders):
                            self.sendRequest(request, andHeaders: newHeaders, allowReAuth: false,
                                             retryPolicy: retryPolicy,
                                             completion: completion)
                        case let .failure(error):
                            self.cancelAllOperations()
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

extension NetworkProxy {
    private func createUploadOperation<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        fromFile fileURL: URL,
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) -> CustomOperation {
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

    private func sendUploadRequest<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        fromFile fileURL: URL,
        allowReAuth: Bool,
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        networkCore.upload(request,
                           andHeaders: headers,
                           fromFile: fileURL,
                           retryPolicy: retryPolicy)
        { result in
            switch result {
            case let .success(model):
                completion(.success(model))
            case let .failure(error):
                if error.errorCode == 401, allowReAuth, let reAuthService = self.reAuthService {
                    reAuthService.reAuthen { reAuthResult in
                        switch reAuthResult {
                        case let .success(newHeaders):
                            self.sendUploadRequest(request,
                                                   andHeaders: newHeaders,
                                                   fromFile: fileURL,
                                                   allowReAuth: false,
                                                   retryPolicy: retryPolicy,
                                                   completion: completion)
                        case let .failure(error):
                            self.cancelAllOperations()
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

extension NetworkProxy {
    private func createDownloadOperation<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) -> CustomOperation {
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

    private func sendDownloadRequest<RequestType: NetworkRequestInterface>(
        _ request: RequestType,
        andHeaders headers: [String: String],
        allowReAuth: Bool,
        retryPolicy: NetworkRetryPolicy,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        networkCore.download(request, andHeaders: headers, retryPolicy: retryPolicy) { result in
            switch result {
            case let .success(model):
                completion(.success(model))
            case let .failure(error):
                if error.errorCode == 401, allowReAuth, let reAuthService = self.reAuthService {
                    reAuthService.reAuthen { reAuthResult in
                        switch reAuthResult {
                        case let .success(newHeaders):
                            self.sendDownloadRequest(request, andHeaders: newHeaders, allowReAuth: false,
                                                     retryPolicy: retryPolicy,
                                                     completion: completion)
                        case let .failure(error):
                            self.cancelAllOperations()
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
