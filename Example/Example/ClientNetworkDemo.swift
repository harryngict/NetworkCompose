//
//  ClientNetworkDemo.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation
import NetworkCompose

/// Typealias for the main network builder using URLSession.
typealias Network = NetworkBuilder<URLSession>

/// Typealias for the network queue builder using URLSession.
typealias NetworkQueue = NetworkQueueBuilder<URLSession>

/// A provider class for managing the main network and network queue instances.
final class NetworkHubProvider {
    /// Constants used by the `NetworkHubProvider`.
    enum Constant {
        static let baseURL: String = "https://jsonplaceholder.typicode.com"
    }

    /// The main network instance.
    let network: Network

    /// The network queue instance.
    let networkQueue: NetworkQueue

    /// Shared instance of the `NetworkHubProvider`.
    static let shared = NetworkHubProvider()

    private init() {
        let baseURL = URL(string: Constant.baseURL)!
        network = NetworkBuilder(baseURL: baseURL)
        networkQueue = NetworkQueueBuilder(baseURL: baseURL)
    }
}

/// A factory class for creating and performing various network requests.
final class ClientNetworkDemo {
    static let shared = ClientNetworkDemo()

    private let network: Network
    private let networkQueue: NetworkQueue

    private init(network: Network = NetworkHubProvider.shared.network,
                 networkQueue: NetworkQueue = NetworkHubProvider.shared.networkQueue)
    {
        self.network = network
        self.networkQueue = networkQueue
    }

    func makeRequest(
        for type: ExampleType,
        completion: @escaping (String) -> Void
    ) {
        switch type {
        case .requestAsync:
            performRequestAsyncAwait(completion: completion)

        case .requestCompletion:
            performRequestCompletion(completion: completion)

        case .requestQueue:
            performReAuthentication(completion: completion)
        case .requestWithSSL:
            performrEnabledSSLPinning(completion: completion)

        case .requestReportMetric:
            performCollectMetricReport(completion: completion)

        case .requestRetry:
            performRequestRetry(completion: completion)

        case .requestSupportAutomation:
            performRequestDemoAutomation(completion: completion)
        }
    }

    private func performRequestAsyncAwait(completion: @escaping (String) -> Void) {
        if #available(iOS 15.0, *) {
            Task {
                do {
                    let request = NetworkRequestBuilder<[User]>(path: "/posts", method: .GET)
                        .build()
                    let service = network.build()
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

        network
            .build()
            .request(request) { (result: Result<[User], NetworkError>) in
                switch result {
                case let .failure(error): completion(error.localizedDescription)
                case let .success(users): completion("\(users)")
                }
            }
    }

    private func performReAuthentication(completion: @escaping (String) -> Void) {
        let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST)
            .setQueryParameters(["title": "foo",
                                 "body": "bar",
                                 "userId": 1])
            .setRequiresReAuthentication(true)
            .build()
        networkQueue
            .setReAuthService(self) // setReAuthService to enable re authentication
            .build()
            .request(request) { (result: Result<User, NetworkError>) in
                switch result {
                case let .failure(error): completion(error.localizedDescription)
                case let .success(user): completion("\(user)")
                }
            }
    }

    private func performrEnabledSSLPinning(completion: @escaping (String) -> Void) {
        do {
            let sslPinningHosts = [NetworkSSLPinningImp(host: "jsonplaceholder.typicode.com",
                                                        hashKeys: ["JCmeBpzLgXemYfoqqEoVJlU/givddwcfIXpwyaBk52I="])]

            let request = NetworkRequestBuilder<User>(path: "/posts/1", method: .PUT)
                .setQueryParameters(["title": "foo",
                                     "body": "bar",
                                     "userId": 1])
                .build()

            try network
                .setSSLPinningPolicy(.trust(sslPinningHosts)) // setSSLPinningPolicy to enable SSLPinning
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

    private func performCollectMetricReport(completion: @escaping (String) -> Void) {
        let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST)
            .build()

        try? network
            .setMetricInterceptor(DebugNetworkMetricInterceptor()) // setMetricInterceptor to report metric
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

        network
            .build()
            .request(request, retryPolicy: .exponentialRetry(count: 3,
                                                             initialDelay: 1,
                                                             multiplier: 2.0,
                                                             maxDelay: 30.0))
        { (result: Result<User, NetworkError>) in
            switch result {
            case let .failure(error): completion(error.localizedDescription)
            case let .success(user): completion("\(user)")
            }
        }
    }

    private func performRequestDemoAutomation(completion: @escaping (String) -> Void) {
        let request = NetworkRequestBuilder<User>(path: "/posts", method: .GET)
            .build()
        network
            .setNetworkStrategy(.mocker(self)) // setNetworkStrategy is mocker
            .build()
            .request(request) { (result: Result<User, NetworkError>) in
                switch result {
                case let .failure(error): completion(error.localizedDescription)
                case let .success(users): completion("\(users)")
                }
            }
    }
}

// MARK: ReAuthenticationService

extension ClientNetworkDemo: ReAuthenticationService {
    /// Re-authenticates the user and provides a new token.
    public func reAuthen(completion: @escaping (Result<[String: String], NetworkError>) -> Void) {
        // For testing now. In fact, this value should get `newtoken` from the real service
        completion(.success(["jwt_token": "newtoken"]))
    }
}

// MARK: NetworkExpectationProvider

extension ClientNetworkDemo: NetworkExpectationProvider {
    /// The network expectations provided by the factory for testing purposes.
    public var networkExpectations: [NetworkCompose.NetworkExpectation] {
        let apiOne = NetworkExpectation(name: "abc",
                                        path: "/posts",
                                        method: .GET,
                                        response: .successResponse(User(id: 1)))
        return [apiOne]
    }
}
