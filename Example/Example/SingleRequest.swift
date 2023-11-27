//
//  SingleRequest.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation
import NetworkCompose

final class SingleRequest {
    static let shared = SingleRequest()

    private let baseURL: URL

    private init() {
        baseURL = URL(string: "https://jsonplaceholder.typicode.com")!
    }

    func makeRequest(
        for scenario: DemoScenario,
        completion: @escaping (Result<[Post], NetworkError>) -> Void
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

        default: break
        }
    }

    private func performCompletionRequest(
        completion: @escaping (Result<[Post], NetworkError>) -> Void
    ) {
        let request = RequestBuilder<[Post]>(path: "/posts", method: .GET)
            .queryParameters(["postId": "1"])
            .build()

        let network = NetworkBuilder<URLSession>(baseURL: baseURL)
        network
            .recordResponseForTesting(.enabled) // Store reponse for automation testing
            .build()
            .request(request) { (result: Result<[Post], NetworkError>) in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(posts): completion(.success(posts))
                }
            }
    }

    private func performReAuthentication(
        completion: @escaping (Result<[Post], NetworkError>) -> Void
    ) {
        let request = RequestBuilder<Post>(path: "/posts", method: .POST)
            .queryParameters(["title": "foo",
                              "body": "bar",
                              "userId": 1])
            .requiresReAuthentication(true)
            .build()

        let network: NetworkBuilder<URLSession> = NetworkBuilder(baseURL: baseURL)
        network
            .reAuthenService(self) // reAuthenService to enable re authentication
            .log(.enabled) // enable log
            .build()
            .request(request) { result in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(post): completion(.success([post]))
                }
            }
    }

    private func performRequestWithEnabledSSLPinning(
        completion: @escaping (Result<[Post], NetworkError>) -> Void
    ) {
        let sslPinningHosts = [SSLPinning(host: "jsonplaceholder.typicode.com",
                                          hashKeys: ["JCmeBpzLgXemYfoqqEoVJlU/givddwcfIXpwyaBk52I="])]

        let request = RequestBuilder<Post>(path: "/posts/1", method: .PUT)
            .queryParameters(["title": "foo",
                              "body": "bar",
                              "userId": 1])
            .build()

        let network: NetworkBuilder<URLSession> = NetworkBuilder(baseURL: baseURL)
        network
            .sslPinningPolicy(.trust(sslPinningHosts)) // sslPinningPolicy to enable SSLPinning
            .log(.enabled)
            .build()
            .request(request) { result in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(post): completion(.success([post]))
                }
            }
    }

    private func performCollectNetworkMetric(
        completion: @escaping (Result<[Post], NetworkError>) -> Void
    ) {
        let request = RequestBuilder<[Post]>(path: "/posts", method: .GET)
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

        let network: NetworkBuilder<URLSession> = NetworkBuilder(baseURL: baseURL)
        network
            .reportMetric(.enabled(metricInterceptor)) // reportMetric to enable report network metric
            .build()
            .request(request) { result in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(posts): completion(.success(posts))
                }
            }
    }

    private func performRequestWithSmartRetry(
        completion: @escaping (Result<[Post], NetworkError>) -> Void
    ) {
        let request = RequestBuilder<Post>(path: "/posts/1/retry", method: .PUT)
            .queryParameters(["title": "foo"])
            .build()

        let retryPolicy: RetryPolicy = .exponentialRetry(count: 4,
                                                         initialDelay: 1,
                                                         multiplier: 3.0,
                                                         maxDelay: 30.0)

        let network: NetworkBuilder<URLSession> = NetworkBuilder(baseURL: baseURL)
        network
            .log(.enabled)
            .build()
            .request(request, retryPolicy: retryPolicy) { result in // retryPolicy to enable retry
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(post): completion(.success([post]))
                }
            }
    }

    private func performRequestDemoAutomation(
        completion: @escaping (Result<[Post], NetworkError>) -> Void
    ) {
        let request = RequestBuilder<[Post]>(path: "/posts", method: .GET)
            .build()

        let concurrentQueue = DispatchQueue(label: "com.NetworkCompose.NetworkComposeDemo",
                                            qos: .userInitiated,
                                            attributes: .concurrent)

        let network: NetworkBuilder<URLSession> = NetworkBuilder(baseURL: baseURL)
        network
            .execute(on: concurrentQueue)
            .observe(on: concurrentQueue)
            .automationMode(.enabled(.local)) // set automationMode for automation tesing
            .log(.enabled)
            .build()
            .request(request) { result in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(posts): completion(.success(posts))
                }
            }
    }
}

// MARK: ReAuthenticationService

extension SingleRequest: ReAuthenticationService {
    public func reAuthen(completion: @escaping (Result<[String: String], NetworkError>) -> Void) {
        // For testing now. In fact, this value should get `newtoken` from the real service
        completion(.success(["jwt_token": "newtoken"]))
    }
}

// MARK: NetworkMockerProvider

extension SingleRequest: EndpointExpectationProvider {
    func getExpectaion(path _: String, method _: NetworkMethod) -> EndpointExpectation {
        let getPostAPIExpectation = EndpointExpectation(path: "/posts",
                                                        method: .GET,
                                                        response: .successResponse(Post(userId: 1,
                                                                                        id: 1,
                                                                                        title: "Hoang")))
        return getPostAPIExpectation
    }
}

// MARK: Helper for demo

private extension SingleRequest {
    func showAlert(_ eventName: String, message: String) {
        let alertController = UIAlertController(title: "Metric event: \(eventName)", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        let topViewController = UIApplication.topViewController()
        topViewController?.present(alertController, animated: true, completion: nil)
    }
}
