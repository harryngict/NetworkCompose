//
//  ClientDemoNetwork.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation
import NetworkCompose

typealias Network = NetworkBuilder<URLSession>
typealias NetworkQueue = NetworkQueueBuilder<URLSession>

final class NetworkHubProvider {
    enum Constant {
        static let baseURL: String = "https://jsonplaceholder.typicode.com"
    }

    let network: Network

    let networkQueue: NetworkQueue

    static let shared = NetworkHubProvider()

    private init() {
        let baseURL = URL(string: Constant.baseURL)!
        network = NetworkBuilder(baseURL: baseURL)
        networkQueue = NetworkQueueBuilder(baseURL: baseURL)
    }
}

final class ClientDemoNetwork {
    static let shared = ClientDemoNetwork()

    private let network: Network
    private let networkQueue: NetworkQueue

    private init(network: Network = NetworkHubProvider.shared.network,
                 networkQueue: NetworkQueue = NetworkHubProvider.shared.networkQueue)
    {
        self.network = network
        self.networkQueue = networkQueue
    }

    func makeRequest(
        for scenario: DemoScenario,
        completion: @escaping (String) -> Void
    ) {
        switch scenario {
        case .asyncWait:
            performAsyncAwaitRequest(completion: completion)

        case .completion:
            performCompletionRequest(completion: completion)

        case .reAuthentication:
            performReAuthentication(completion: completion)

        case .enabledSSLPinning:
            performRequestWithEnabledSSLPinning(completion: completion)

        case .networkMetricReport:
            performCollectNetworkMetric(completion: completion)

        case .smartRetry:
            performRequestWithSmartRetry(completion: completion)

        case .supportAutomationTest:
            performRequestDemoAutomation(completion: completion)
        }
    }

    private func performAsyncAwaitRequest(completion: @escaping (String) -> Void) {
        if #available(iOS 15.0, *) {
            Task {
                do {
                    let request = NetworkRequestBuilder<[User]>(path: "/posts", method: .GET)
                        .build()

                    let result: [User] = try await network
                        .setDefaultConfiguration()
                        .build().request(request)
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

        network
            .setDefaultConfiguration()
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
            .setDefaultConfiguration()
            .setReAuthService(self) // setReAuthService to enable re authentication
            .build()
            .request(request) { (result: Result<User, NetworkError>) in
                switch result {
                case let .failure(error): completion(error.localizedDescription)
                case let .success(user): completion("\(user)")
                }
            }
    }

    private func performRequestWithEnabledSSLPinning(completion: @escaping (String) -> Void) {
        do {
            let sslPinningHosts = [NetworkSSLPinningImp(host: "jsonplaceholder.typicode.com",
                                                        hashKeys: ["JCmeBpzLgXemYfoqqEoVJlU/givddwcfIXpwyaBk52I="])]

            let request = NetworkRequestBuilder<User>(path: "/posts/1", method: .PUT)
                .setQueryParameters(["title": "foo",
                                     "body": "bar",
                                     "userId": 1])
                .build()

            try network
                .setDefaultConfiguration()
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

    private func performCollectNetworkMetric(completion: @escaping (String) -> Void) {
        let request = NetworkRequestBuilder<User>(path: "/posts", method: .POST)
            .build()

        try? network
            .setDefaultConfiguration()
            .setMetricInterceptor(DebugNetworkMetricInterceptor()) // setMetricInterceptor to report metric
            .build()
            .request(request) { (result: Result<User, NetworkError>) in
                switch result {
                case let .failure(error): completion(error.localizedDescription)
                case let .success(user): completion("\(user)")
                }
            }
    }

    private func performRequestWithSmartRetry(completion: @escaping (String) -> Void) {
        let request = NetworkRequestBuilder<User>(path: "/posts/1/retry", method: .PUT)
            .setQueryParameters(["title": "foo"])
            .build()

        network
            .setDefaultConfiguration()
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
            .setDefaultConfiguration()
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

extension ClientDemoNetwork: ReAuthenticationService {
    /// Re-authenticates the user and provides a new token.
    public func reAuthen(completion: @escaping (Result<[String: String], NetworkError>) -> Void) {
        // For testing now. In fact, this value should get `newtoken` from the real service
        completion(.success(["jwt_token": "newtoken"]))
    }
}

// MARK: NetworkExpectationProvider

extension ClientDemoNetwork: NetworkExpectationProvider {
    /// The network expectations provided by the factory for testing purposes.
    public var networkExpectations: [NetworkCompose.NetworkExpectation] {
        let apiOne = NetworkExpectation(name: "abc",
                                        path: "/posts",
                                        method: .GET,
                                        response: .successResponse(User(id: 1)))
        return [apiOne]
    }
}
