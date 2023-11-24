//
//  ClientNetworkFactory.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation
import NetworkCompose

enum Constant {
    static let baseURL: String = "https://jsonplaceholder.typicode.com"
}

/// A factory class for creating and performing network requests using various request types.
public class ClientNetworkFactory {
    /// The base URL for network requests.
    private let baseURL: URL

    /// Initializes the `ClientNetworkFactory` with a base URL.
    ///
    /// - Parameter baseURL: The base URL for network requests.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    // MARK: Request Methods

    /// Makes a network request based on the specified `ExampleType`.
    ///
    /// - Parameters:
    ///   - type: The type of example request to perform.
    ///   - completion: A closure called with the result of the network request.
    func makeRequest(
        for type: ExampleType,
        completion: @escaping (String) -> Void
    ) {
        switch type {
        case .requestAsync: performRequestAsyncAwait(completion: completion)
        case .requestCompletion: performRequestCompletion(completion: completion)
        case .requestQueue: performRequestQueue(completion: completion)
        case .requestWithSSL: performRequestWithSSL(completion: completion)
        case .requestReportMetric: performRequestReportMetric(completion: completion)
        case .requestRetry: performRequestRetry(completion: completion)
        case .requestMock: performRequestMock(completion: completion)
        }
    }

    private func performRequestAsyncAwait(completion: @escaping (String) -> Void) {
        if #available(iOS 15.0, *) {
            Task {
                do {
                    let request = NetworkRequestBuilder<[User]>(path: "/posts", method: .GET)
                        .build()
                    let service = NetworkCoreBuilder(baseURL: baseURL).build()
                    let result: [User] = try await service.request(request)
                    completion("\(result)")
                } catch {
                    completion((error as? NetworkError)?.localizedDescription ?? error.localizedDescription)
                }
            }
        }
    }

    private func performRequestCompletion(completion: @escaping (String) -> Void) {
        let request = NetworkRequestBuilder<[User]>(path: "/comments", method: .GET)
            .setQueryParameters(["postId": "1"])
            .build()

        NetworkCoreBuilder(baseURL: baseURL)
            .build()
            .request(request) { (result: Result<[User], NetworkError>) in
                switch result {
                case let .failure(error): completion(error.localizedDescription)
                case let .success(users): completion("\(users)")
                }
            }
    }

    private func performRequestQueue(completion: @escaping (String) -> Void) {
        let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST)
            .setQueryParameters(["title": "foo",
                                 "body": "bar",
                                 "userId": 1])
            .setRequiresReAuthentication(true)
            .build()
        NetworkQueueBuilder(baseURL: baseURL)
            .setReAuthService(ClientReAuthenticationService())
            .build()
            .request(request) { (result: Result<User, NetworkError>) in
                switch result {
                case let .failure(error): completion(error.localizedDescription)
                case let .success(user): completion("\(user)")
                }
            }
    }

    private func performRequestWithSSL(completion: @escaping (String) -> Void) {
        do {
            let sslPinningHosts = [NetworkSSLPinningImp(host: "jsonplaceholder.typicode.com",
                                                        hashKeys: ["JCmeBpzLgXemYfoqqEoVJlU/givddwcfIXpwyaBk52I="])]

            let request = NetworkRequestBuilder<User>(path: "/posts/1", method: .PUT)
                .setQueryParameters(["title": "foo",
                                     "body": "bar",
                                     "userId": 1])
                .build()

            try NetworkCoreBuilder(baseURL: baseURL)
                .setSSLPinningPolicy(.trust(sslPinningHosts))
                .build()
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

    private func performRequestReportMetric(completion: @escaping (String) -> Void) {
        let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST)
            .build()

        try? NetworkCoreBuilder(baseURL: baseURL)
            .setMetricInterceptor(LocalNetworkMetricInterceptor())
            .build()
            .request(request) { (result: Result<User, NetworkError>) in
                switch result {
                case let .failure(error): completion(error.localizedDescription)
                case let .success(user): completion("\(user)")
                }
            }
    }

    private func performRequestRetry(completion: @escaping (String) -> Void) {
        let request = NetworkRequestBuilder<User>(path: "/posts/1/retry", method: .PUT)
            .setQueryParameters(["title": "foo"])
            .build()

        NetworkCoreBuilder(baseURL: baseURL)
            .build()
            .request(request, retryPolicy: .retry(count: 2, delay: 5)) { (result: Result<User, NetworkError>) in
                switch result {
                case let .failure(error): completion(error.localizedDescription)
                case let .success(user): completion("\(user)")
                }
            }
    }

    private func performRequestMock(completion: @escaping (String) -> Void) {
        let successResult = NetworkResultMock.requestSuccess(
            NetworkResponseMock(statusCode: 200, response: User(id: 1))
        )
        let session = NetworkSessionMock<User>(expected: successResult)
        let service = NetworkCoreBuilder<NetworkSessionMock>(baseURL: baseURL, session: session).build()
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
