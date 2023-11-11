//
//  ClientNetworkFactory.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation
import NetworkKit

final class ClientNetworkFactory {
    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    private func handleResult<T>(
        _ result: Result<T, NetworkError>,
        completion: @escaping (String) -> Void
    ) {
        switch result {
        case let .success(model): completion("\(model)")
        case let .failure(error): completion(error.localizedDescription)
        }
    }

    // MARK: Request Methods

    func makeRequest(
        for type: ExampleType,
        completion: @escaping (String) -> Void
    ) {
        switch type {
        case .requestAsync:
            if #available(iOS 15.0, *) {
                performAsyncAwait(completion: completion)
            }
        case .requestCompletion: performRequest(completion: completion)
        case .requestQueue: performQueueRequest(completion: completion)
        case .uploadFile: performUploadFileRequest(completion: completion)
        case .downloadFile: performDownloadFileRequest(completion: completion)
        case .requestMock: performMockRequest(completion: completion)
        }
    }

    // MARK: Request Helper Methods

    private func performRequest(
        completion: @escaping (String) -> Void
    ) {
        let credentialContainer = ClientCredentialContainer()
        let trustSessionDelegate = ClientTrustSessionDelegate()
        let session = URLSession(configuration: .default,
                                 delegate: trustSessionDelegate,
                                 delegateQueue: nil)
        let service = NetworkKitImpWrapper(baseURL: baseURL,
                                           session: session,
                                           credentialContainer: credentialContainer)
        let request = ClientRequest<[User]>(path: "/users", method: .GET)
        service.request(request) { result in
            self.handleResult(result, completion: completion)
        }
    }

    private func performQueueRequest(
        completion: @escaping (String) -> Void
    ) {
        let credentialContainer = ClientCredentialContainer()
        let reAuthService = ClientReAuthenticationService(credentialContainer: credentialContainer)
        let networkKitQueue = NetworkKitQueueImp(baseURL: baseURL,
                                                 credentialContainer: credentialContainer,
                                                 reAuthService: reAuthService)
        let request = ClientRequest<User>(path: "/users/1", method: .PUT)
        networkKitQueue.request(request) { result in
            self.handleResult(result, completion: completion)
        }
    }

    private func performUploadFileRequest(
        completion: @escaping (String) -> Void
    ) {
        let uploadDelegate = ClientUploadDelegate()
        let session = URLSession(configuration: .default, delegate: uploadDelegate, delegateQueue: nil)
        let uploadService = NetworkKitImpWrapper(baseURL: baseURL, session: session)
        let request = ClientRequest<User>(path: "/users/2", method: .POST)

        uploadService.uploadFile(request, fromFile: URL(fileURLWithPath: "")) { result in
            self.handleResult(result, completion: completion)
        }
    }

    private func performDownloadFileRequest(
        completion: @escaping (String) -> Void
    ) {
        let downloadDelegate = ClientDownloadDelegate()
        let session = URLSession(configuration: .default, delegate: downloadDelegate, delegateQueue: nil)
        let downloadService = NetworkKitImpWrapper(baseURL: baseURL, session: session)
        let request = ClientRequest<User>(path: "/users/2", method: .POST)

        downloadService.downloadFile(request) { result in
            self.handleResult(result, completion: completion)
        }
    }

    private func performMockRequest(
        completion: @escaping (String) -> Void
    ) {
        let successResult = NetworkKitResultMock.requestSuccess(
            NetworkResponseMock(statusCode: 200, response: [User(id: "1", name: "Hoang")])
        )
        let session = NetworkSessionMock<User>(expected: successResult)
        let service = NetworkKitImpWrapper<NetworkSessionMock>(baseURL: baseURL, session: session)
        let request = ClientRequest<[User]>(path: "/users", method: .GET)

        service.request(request) { result in
            self.handleResult(result, completion: completion)
        }
    }

    @available(iOS 15.0, *)
    private func performAsyncAwait(
        completion: @escaping (String) -> Void
    ) {
        Task {
            do {
                let credentialContainer = ClientCredentialContainer()
                let request = ClientRequest<User>(path: "/users/6", method: .DELETE)
                let service = NetworkKitImpWrapper(baseURL: baseURL, credentialContainer: credentialContainer)
                let result: ClientRequest<User>.SuccessType = try await service.request(request)
                completion("\(result)")
            } catch {
                completion((error as? NetworkError)?.localizedDescription ?? error.localizedDescription)
            }
        }
    }
}
