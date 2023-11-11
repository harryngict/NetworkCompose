//
//  NetworkKitQueueImp.swift
//  NetworkQueue/Implementation
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

public class NetworkKitQueueImp<SessionType: NetworkSession>: NetworkKitQueue {
    private let networkKit: NetworkKit
    private let serialOperationQueue: OperationQueueManager
    public let reAuthService: ReAuthenticationService

    // MARK: Initialization

    public init(
        baseURL: URL,
        session: SessionType = URLSession.shared,
        credentialContainer: NetworkCredentialContainer? = nil,
        reAuthService: ReAuthenticationService,
        serialOperationQueue: OperationQueueManager = OperationQueueManagerImp(maxConcurrentOperationCount: 1)
    ) {
        networkKit = NetworkKitImp(baseURL: baseURL, session: session, credentialContainer: credentialContainer)
        self.reAuthService = reAuthService
        self.serialOperationQueue = serialOperationQueue
    }

    // MARK: Public Methods

    public func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        if request.requiresCredentials {
            let operation = createOperation(request, completion: completion)
            serialOperationQueue.enqueue(operation)
        } else {
            sendRequest(request, allowReAuth: false, completion: completion)
        }
    }

    // MARK: Private Methods

    // MARK: Create ReAuthenOperation

    private func createOperation<RequestType: NetworkRequest>(
        _ request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) -> CustomOperation {
        let asyncOperation = ClosureCustomOperation { operation in
            operation.state = .executing
            self.sendRequest(request, allowReAuth: request.requiresCredentials) { result in
                switch result {
                case let .success(model): completion(.success(model))
                case let .failure(error): completion(.failure(error))
                }
                operation.state = .finished
            }
        }

        return asyncOperation
    }

    // MARK: NetworkService send request

    private func sendRequest<RequestType: NetworkRequest>(
        _ request: RequestType,
        allowReAuth: Bool,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        networkKit.request(request) { result in
            switch result {
            case let .success(model):
                completion(.success(model))
            case let .failure(error):
                if error.errorCode == 401, allowReAuth {
                    self.executeReAuthen(completion: { reAuthResult in
                        switch reAuthResult {
                        case .success: self.sendRequest(request, allowReAuth: false, completion: completion)
                        case let .failure(error): completion(.failure(error))
                        }
                    })
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: Execute re-authentication

    private func executeReAuthen(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        reAuthService.execute { result in
            switch result {
            case .success: completion(.success(()))
            case let .failure(error): self.handleReAuthFailure(error: error, completion: completion)
            }
        }
    }

    private func handleReAuthFailure(error: NetworkError, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        cancelAllOperations()
        completion(.failure(error))
    }

    private func cancelAllOperations() {
        guard let operations = serialOperationQueue.operationQueue.operations as? [ClosureCustomOperation] else {
            return
        }
        for operation in operations {
            operation.validOperation = false
        }
    }
}
