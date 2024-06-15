//
//  SingleRequest.swift
//  Example
//
//  Created by Hoang Nguyezn on 18/11/23.
//

import Foundation
import NetworkCompose
import NetworkComposeImp

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
        let request = RequestBuilder<[Post]>(path: "/posts", method: .GET).queryParameters(["postId": "1"]).build()

        let network = NetworkBuilder<URLSession>(baseURL: baseURL)
        network
            .logger(.enabled)
            .build()
            .request(request) { (result: Result<[Post], NetworkError>) in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(posts): completion(.success(posts))
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
            .sslPinningPolicy(.trust(sslPinningHosts))
            .logger(.enabled)
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
                debugPrint("MetricInterceptor report metric: \(metricReport)")
            }
        }

        let network: NetworkBuilder<URLSession> = NetworkBuilder(baseURL: baseURL)
        network
            .reportMetric(.enabled(metricInterceptor))
            .logger(.enabled)
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
            .logger(.enabled)
            .build()
            .request(request, retryPolicy: retryPolicy) { result in
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
            .queryParameters(["postId": "1"])
            .build()

        let concurrentQueue = DispatchQueue(label: "\(LibraryConstant.domain).SingleRequest",
                                            qos: .userInitiated,
                                            attributes: .concurrent)

        let network: NetworkBuilder<URLSession> = NetworkBuilder(baseURL: baseURL)
        network
            .execute(on: concurrentQueue)
            .observe(on: concurrentQueue)
            .logger(.enabled)
            .build()
            .request(request) { result in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(posts): completion(.success(posts))
                }
            }
    }
}
