//
//  NetworkComposeDemo.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation
import NetworkCompose

final class NetworkComposeDemo {
    enum Constant {
        static let baseURL: String = "https://jsonplaceholder.typicode.com"
    }

    static let shared = NetworkComposeDemo()

    private let network: NetworkBuilder<URLSession>

    private init() {
        let baseURL = URL(string: Constant.baseURL)!
        network = NetworkBuilder(baseURL: baseURL)
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
        let request = RequestBuilder<[Article]>(path: "/posts", method: .GET)
            .queryParameters(["postId": "1"])
            .build()

        network
            .applyDefaultConfiguration() //  reset all configurations
            .recordResponseForTesting(.enabled) // Store reponse for automation testing
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
        let request = RequestBuilder<Article>(path: "/posts", method: .POST)
            .queryParameters(["title": "foo",
                              "body": "bar",
                              "userId": 1])
            .requiresReAuthentication(true)
            .build()

        let retryPolicy: RetryPolicy = .exponentialRetry(count: 4,
                                                         initialDelay: 1,
                                                         multiplier: 3.0,
                                                         maxDelay: 30.0)
        network
            .applyDefaultConfiguration() //  reset all configurations
            .reAuthenService(self) // reAuthenService to enable re authentication
            .log(.enabled)
            .request(request, retryPolicy: retryPolicy) { (result: Result<Article, NetworkError>) in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(user): completion(.success([user]))
                }
            }
    }

    private func performRequestWithEnabledSSLPinning(
        completion: @escaping (Result<[Article], NetworkError>) -> Void
    ) {
        let sslPinningHosts = [SSLPinning(host: "jsonplaceholder.typicode.com",
                                          hashKeys: ["JCmeBpzLgXemYfoqqEoVJlU/givddwcfIXpwyaBk52I="])]

        let request = RequestBuilder<Article>(path: "/posts/1", method: .PUT)
            .queryParameters(["title": "foo",
                              "body": "bar",
                              "userId": 1])
            .build()

        network
            .applyDefaultConfiguration() //  reset all configurations
            .sslPinningPolicy(.trust(sslPinningHosts)) // setSSLPinningPolicy to enable SSLPinning
            .log(.enabled)
            .request(request) { (result: Result<Article, NetworkError>) in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(user): completion(.success([user]))
                }
            }
    }

    private func performCollectNetworkMetric(
        completion: @escaping (Result<[Article], NetworkError>) -> Void
    ) {
        let request = RequestBuilder<[Article]>(path: "/posts", method: .GET)
            .build()
        let metricInterceptor = MetricInterceptor { event in
            let taskMetric: TaskMetric = event.metric
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            if let metricReport = try? String(data: encoder.encode(taskMetric), encoding: .utf8) {
                DispatchQueue.main.async { self.showAlert(event.name, message: "\n\(metricReport)") }
            }
        }
        network
            .applyDefaultConfiguration() //  reset all configurations
            .reportMetric(.enabled(metricInterceptor))
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
        let request = RequestBuilder<Article>(path: "/posts/1/retry", method: .PUT)
            .queryParameters(["title": "foo"])
            .build()

        let retryPolicy: RetryPolicy = .exponentialRetry(count: 4,
                                                         initialDelay: 1,
                                                         multiplier: 3.0,
                                                         maxDelay: 30.0)
        network
            .applyDefaultConfiguration() //  reset all configurations
            .log(.enabled)
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
        let request = RequestBuilder<[Article]>(path: "/posts", method: .GET)
            .build()

        let concurrentQueue = DispatchQueue(label: "com.NetworkCompose.NetworkComposeDemo",
                                            qos: .userInitiated,
                                            attributes: .concurrent)
        network
            .applyDefaultConfiguration() //  reset all configurations
            .execute(on: concurrentQueue)
            .observe(on: concurrentQueue)
            .automationMode(.enabled(.local)) // set datasource for automation tesing
            .log(.enabled)
            .request(request) { (result: Result<[Article], NetworkError>) in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(users): completion(.success(users))
                }
            }
    }
}

// MARK: ReAuthenticationService

extension NetworkComposeDemo: ReAuthenticationService {
    public func reAuthen(completion: @escaping (Result<[String: String], NetworkError>) -> Void) {
        // For testing now. In fact, this value should get `newtoken` from the real service
        completion(.success(["jwt_token": "newtoken"]))
    }
}

// MARK: NetworkMockerProvider

extension NetworkComposeDemo: EndpointExpectationProvider {
    func getExpectaion(path _: String, method _: NetworkCompose.NetworkMethod) -> NetworkCompose.EndpointExpectation {
        let getPostAPIExpectation = EndpointExpectation(name: "get-posts-api",
                                                        path: "/posts",
                                                        method: .GET,
                                                        response: .successResponse(Article(id: 1,
                                                                                           title: "Automation",
                                                                                           name: "Hoang")))
        return getPostAPIExpectation
    }
}

// MARK: Helper for demo

private extension NetworkComposeDemo {
    func showAlert(_ eventName: String, message: String) {
        let alertController = UIAlertController(title: "Metric event: \(eventName)", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        let topViewController = UIApplication.topViewController()
        topViewController?.present(alertController, animated: true, completion: nil)
    }
}

struct Article: Codable, Hashable {
    let id: Int
    let title: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id, title, name
    }
}

enum DemoScenario: String {
    case defaultRequest = "Demo default request"
    case reAuthentication = "Demo reauthentication request"
    case enabledSSLPinning = "Demo enabled SSL Pinning request"
    case networkMetricReport = "Demo collect metric report"
    case smartRetry = "Demo smart retry request"
    case supportAutomationTest = "Demo suppport automation testing"
}
