//
//  ClientDemoNetwork.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation
import NetworkCompose

final class ClientDemoNetwork {
    enum Constant {
        static let baseURL: String = "https://jsonplaceholder.typicode.com"
    }

    static let shared = ClientDemoNetwork()

    private let network: NetworkCompose<URLSession>

    private init() {
        let baseURL = URL(string: Constant.baseURL)!
        network = NetworkCompose(baseURL: baseURL)
    }

    func makeRequest(
        for scenario: DemoScenario,
        completion: @escaping (Result<[Article], NetworkError>) -> Void
    ) {
        switch scenario {
        case .defaultRequest:
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

    private func performCompletionRequest(
        completion: @escaping (Result<[Article], NetworkError>) -> Void
    ) {
        let request = NetworkRequest<[Article]>(path: "/comments", method: .GET)
            .setQueryParameters(["postId": "1"])
            .build()

        network
            .setDefaultConfiguration() //  reset all configurations
            .build()
            .request(request) { (result: Result<[Article], NetworkError>) in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(users): completion(.success(users))
                }
            }
    }

    private func performReAuthentication(
        completion: @escaping (Result<[Article], NetworkError>) -> Void
    ) {
        let request = NetworkRequest<Article>(path: "/posts", method: .POST)
            .setQueryParameters(["title": "foo",
                                 "body": "bar",
                                 "userId": 1])
            .setRequiresReAuthentication(true)
            .build()

        network
            .setDefaultConfiguration() //  reset all configurations
            .setReAuthService(self) // setReAuthService to enable re authentication
            .build()
            .request(request) { (result: Result<Article, NetworkError>) in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(user): completion(.success([user]))
                }
            }
    }

    private func performRequestWithEnabledSSLPinning(
        completion: @escaping (Result<[Article], NetworkError>) -> Void
    ) {
        do {
            let sslPinningHosts = [NetworkSSLPinningImp(host: "jsonplaceholder.typicode.com",
                                                        hashKeys: ["JCmeBpzLgXemYfoqqEoVJlU/givddwcfIXpwyaBk52I="])]

            let request = NetworkRequest<Article>(path: "/posts/1", method: .PUT)
                .setQueryParameters(["title": "foo",
                                     "body": "bar",
                                     "userId": 1])
                .build()

            try network
                .setDefaultConfiguration() //  reset all configurations
                .setSSLPinningPolicy(.trust(sslPinningHosts)) // setSSLPinningPolicy to enable SSLPinning
                .build()
                .request(request) { (result: Result<Article, NetworkError>) in
                    switch result {
                    case let .failure(error): completion(.failure(error))
                    case let .success(user): completion(.success([user]))
                    }
                }
        } catch {
            completion(.failure(NetworkError.error(nil, error.localizedDescription)))
        }
    }

    private func performCollectNetworkMetric(
        completion: @escaping (Result<[Article], NetworkError>) -> Void
    ) {
        let request = NetworkRequest<[Article]>(path: "/posts", method: .GET)
            .build()

        try? network
            .setDefaultConfiguration() //  reset all configurations
            .setMetricInterceptor(DefaultNetworkMetricInterceptor { event in // setMetricInterceptor to report metric
                DispatchQueue.main.async { self.showMessageForMetricEvent(event) }
            })
            .build()
            .request(request) { (result: Result<[Article], NetworkError>) in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(users): completion(.success(users))
                }
            }
    }

    private func performRequestWithSmartRetry(
        completion: @escaping (Result<[Article], NetworkError>) -> Void
    ) {
        let request = NetworkRequest<Article>(path: "/posts/1/retry", method: .PUT)
            .setQueryParameters(["title": "foo"])
            .build()

        // exponential retry
        let retryPolicy: NetworkRetryPolicy = .exponentialRetry(count: 4,
                                                                initialDelay: 1,
                                                                multiplier: 3.0,
                                                                maxDelay: 30.0)
        network
            .setDefaultConfiguration() //  reset all configurations
            .build()
            .request(request, retryPolicy: retryPolicy) { (result: Result<Article, NetworkError>) in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(user): completion(.success([user]))
                }
            }
    }

    private func performRequestDemoAutomation(
        completion: @escaping (Result<[Article], NetworkError>) -> Void
    ) {
        let request = NetworkRequest<Article>(path: "/posts", method: .GET)
            .build()

        network
            .setDefaultConfiguration() //  reset all configurations
            .setNetworkStrategy(.mocker(self)) // setNetworkStrategy is mocker
            .build()
            .request(request) { (result: Result<Article, NetworkError>) in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(user): completion(.success([user]))
                }
            }
    }
}

// MARK: ReAuthenticationService

extension ClientDemoNetwork: ReAuthenticationService {
    public func reAuthen(completion: @escaping (Result<[String: String], NetworkError>) -> Void) {
        // For testing now. In fact, this value should get `newtoken` from the real service
        completion(.success(["jwt_token": "newtoken"]))
    }
}

// MARK: NetworkExpectationProvider

extension ClientDemoNetwork: NetworkExpectationProvider {
    public var networkExpectations: [NetworkExpectation] {
        let getPostAPIExpectation = NetworkExpectation(name: "get-posts-api",
                                                       path: "/posts",
                                                       method: .GET,
                                                       response: .successResponse(Article(id: 1,
                                                                                          title: "Automation",
                                                                                          name: "Hoang")))
        return [getPostAPIExpectation]
    }
}

private extension ClientDemoNetwork {
    func showMessageForMetricEvent(_ event: NetworkTaskEvent) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        let metricReport = try? String(data: encoder.encode(event.taskMetric), encoding: .utf8)
        showAlert(event.name, message: metricReport ?? "")
    }

    func showAlert(_ eventName: String, message: String) {
        let alertController = UIAlertController(title: "Metric event: \(eventName)", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        let topViewController = UIApplication.topViewController()
        topViewController?.present(alertController, animated: true, completion: nil)
    }
}
