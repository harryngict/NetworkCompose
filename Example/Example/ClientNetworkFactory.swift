//
//  ClientNetworkFactory.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation
import NetworkSwift

enum Constant {
    static let baseURL: String = "https://jsonplaceholder.typicode.com"
}

final class ClientNetworkFactory {
    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    // MARK: Request Methods

    func makeRequest(
        for type: ExampleType,
        completion: @escaping (String) -> Void
    ) {
        switch type {
        case .requestAsync: performAsyncAwait(completion: completion)
        case .requestCompletion: performCompletionRequest(completion: completion)
        case .requestQueue: performQueueRequest(completion: completion)
        case .uploadFile: performUploadFileRequest(completion: completion)
        case .downloadFile: performDownloadFileRequest(completion: completion)
        case .requestWithSSL: performRequestWithSSL(completion: completion)
        case .requestQueueWithSSL: performRequestQueueWithSSL(completion: completion)
        case .requestMock: performMockRequest(completion: completion)
        }
    }

    // MARK: Request Helper Methods

    private func performAsyncAwait(completion: @escaping (String) -> Void) {
        if #available(iOS 15.0, *) {
            Task {
                do {
                    let request = NetworkRequestBuilder<[User]>(path: "/posts", method: .GET)
                        .build()
                    let service = NetworkKitBuilder(baseURL: baseURL).build()
                    let result: [User] = try await service.request(request)
                    completion("\(result)")
                } catch {
                    completion((error as? NetworkError)?.localizedDescription ?? error.localizedDescription)
                }
            }
        }
    }

    private func performCompletionRequest(completion: @escaping (String) -> Void) {
        let request = NetworkRequestBuilder<[User]>(path: "/comments", method: .GET)
            .setQueryParameters(["postId": "1"])
            .build()

        let service = NetworkKitBuilder(baseURL: baseURL)

        service.request(request, retryPolicy: .retry(count: 5)) { (result: Result<[User], NetworkError>) in
            switch result {
            case let .failure(error): completion(error.localizedDescription)
            case let .success(users): completion("\(users)")
            }
        }
    }

    private func performQueueRequest(completion: @escaping (String) -> Void) {
        let reAuthService = ClientReAuthenticationService()
        let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST)
            .setQueryParameters(["title": "foo",
                                 "body": "bar",
                                 "userId": 1])
            .setRequiresReAuthentication(true)
            .build()
        let service = NetworkKitQueueBuilder(baseURL: baseURL).setReAuthService(reAuthService).build()
        service.request(request) { (result: Result<User, NetworkError>) in
            switch result {
            case let .failure(error): completion(error.localizedDescription)
            case let .success(user): completion("\(user)")
            }
        }
    }

    private func performDownloadFileRequest(completion: @escaping (String) -> Void) {
        let request = NetworkRequestBuilder<User>(path: "/posts/1", method: .PUT)
            .setQueryParameters(["title": "foo",
                                 "body": "bar",
                                 "userId": 1])
            .build()
        let service = NetworkKitBuilder(baseURL: baseURL).build()
        service.downloadFile(request) { (result: Result<URL, NetworkError>) in
            switch result {
            case let .failure(error): completion(error.localizedDescription)
            case let .success(url): completion("\(url.absoluteString)")
            }
        }
    }

    private func performUploadFileRequest(completion: @escaping (String) -> Void) {
        let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST)
            .build()
        let fileURL = URL(fileURLWithPath: "/Users/harrynguyen/Documents/Resources/NetworkSwift/LICENSE")

        let service = NetworkKitBuilder(baseURL: baseURL).build()
        service.uploadFile(request, fromFile: fileURL) { (result: Result<User, NetworkError>) in
            switch result {
            case let .failure(error): completion(error.localizedDescription)
            case let .success(user): completion("\(user)")
            }
        }
    }

    private func performRequestWithSSL(completion: @escaping (String) -> Void) {
        do {
            let sslPinningHosts = [NetworkSSLPinningHostImp(host: "jsonplaceholder.typicode.com",
                                                            pinningHash: ["JCmeBpzLgXemYfoqqEoVJlU/givddwcfIXpwyaBk52I="])]
            let securityTrust = NetworkSecurityTrustImp(sslPinningHosts: sslPinningHosts)

            let request = NetworkRequestBuilder<User>(path: "/posts/1", method: .PUT)
                .setQueryParameters(["title": "foo",
                                     "body": "bar",
                                     "userId": 1])
                .build()

            try NetworkKitBuilder(baseURL: baseURL)
                .setSecurityTrust(securityTrust)
                .setMetricsCollector(NetworkMetricsCollectorImp())
                .request(request) { (result: Result<User, NetworkError>) in
                    switch result {
                    case let .failure(error): completion(error.localizedDescription)
                    case let .success(users): completion("\(users)")
                    }
                }
        } catch {
            completion(error.localizedDescription)
        }
    }

    private func performRequestQueueWithSSL(completion: @escaping (String) -> Void) {
        do {
            let sslPinningHosts = [NetworkSSLPinningHostImp(host: "jsonplaceholder.typicode.com",
                                                            pinningHash: ["JCmeBpzLgXemYfoqqEoVJlU/givddwcfIXpwyaBk52I="])]
            let securityTrust = NetworkSecurityTrustImp(sslPinningHosts: sslPinningHosts)

            let request = NetworkRequestBuilder<User>(path: "/posts/1", method: .PATCH)
                .setQueryParameters(["title": "foo"])
                .build()

            try NetworkKitQueueBuilder(baseURL: baseURL)
                .setSecurityTrust(securityTrust)
                .setMetricsCollector(NetworkMetricsCollectorImp())
                .setReAuthService(ClientReAuthenticationService())
                .request(request) { (result: Result<User, NetworkError>) in
                    switch result {
                    case let .failure(error): completion(error.localizedDescription)
                    case let .success(users): completion("\(users)")
                    }
                }
        } catch {
            completion(error.localizedDescription)
        }
    }

    private func performMockRequest(completion: @escaping (String) -> Void) {
        let successResult = NetworkKitResultMock.requestSuccess(
            NetworkResponseMock(statusCode: 200, response: User(id: 1))
        )
        let session = NetworkSessionMock<User>(expected: successResult)
        let service = NetworkKitBuilder<NetworkSessionMock>(baseURL: baseURL, session: session).build()
        let request = NetworkRequestBuilder<User>(path: "/posts", method: .GET)
            .build()

        service.request(request) { (result: Result<User, NetworkError>) in
            switch result {
            case let .failure(error): completion(error.localizedDescription)
            case let .success(users): completion("\(users)")
            }
        }
    }
}
