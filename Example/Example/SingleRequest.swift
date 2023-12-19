//
//  SingleRequest.swift
//  Example
//
//  Created by Hoang Nguyezn on 18/11/23.
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
        case .download:
            download(completion: completion)

        case .upload:
            upload(completion: completion)

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
            .recordResponseForTesting(.enabled)
            .logger(.enabled)
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
            .reAuthenService(self)
            .logger(.enabled)
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

    private func download(
        completion: @escaping (Result<[Post], NetworkError>) -> Void
    ) {
        let request = RequestBuilder<[Post]>(path: "/posts", method: .GET)
            .build()
        let sessionProxyDelegate = SessionProxyDelegate()
        sessionProxyDelegate.downloadProgressHandler = { progress in
            print("Download progress: \(progress)")
        }
        sessionProxyDelegate.completionHandler = { _, error in
            print("Download finish: \(String(describing: error?.localizedDescription))")
        }
        guard let network: NetworkBuilder<URLSession> = try? NetworkBuilder<URLSession>(baseURL: baseURL,
                                                                                        sessionProxyDelegate: sessionProxyDelegate,
                                                                                        sessionConfigurationType: .ephemeral)
        else {
            return
        }
        network.build()
            .download(request) { result in
                switch result {
                case let .failure(error): completion(.failure(error))
                case let .success(posts): completion(.success(posts))
                }
            }
    }

    private func upload(
        completion: @escaping (Result<[Post], NetworkError>) -> Void
    ) {
        let request = RequestBuilder<Post>(path: "/posts", method: .POST)
            .queryParameters(["title": "foo",
                              "body": "bar",
                              "userId": 1])
            .requiresReAuthentication(true)
            .build()

        let file = URL(fileURLWithPath: "/Users/harrynguyen/Documents/Resources/NetworkCompose/Example/Example/747.png")
        let sessionProxyDelegate = SessionProxyDelegate()
        sessionProxyDelegate.uploadProgressHandler = { progress in
            print("Upload progress: \(progress)")
        }
        sessionProxyDelegate.completionHandler = { _, error in
            print("Upload finish: \(String(describing: error?.localizedDescription))")
        }
        guard let network: NetworkBuilder<URLSession> = try? NetworkBuilder<URLSession>(baseURL: baseURL,
                                                                                        sessionProxyDelegate: sessionProxyDelegate,
                                                                                        sessionConfigurationType: .ephemeral)
        else {
            return
        }
        network
            .reAuthenService(self)
            .logger(.enabled)
            .build()
            .upload(request, fromFile: file) { result in
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
            .automationMode(.enabled(.local))
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

// MARK: ReAuthenticationService

extension SingleRequest: ReAuthenticationService {
    public func reAuthen(completion: @escaping (Result<[String: String], NetworkError>) -> Void) {
        // For testing now. In fact, this value should get `newtoken` from the real service
        completion(.success(["jwt_token": "newtoken"]))
    }
}

// MARK: NetworkMockerProvider

extension SingleRequest: EndpointExpectationProvider {
    func expectation(for _: String,
                     method _: NetworkCompose.NetworkMethod,
                     queryParameters _: [String: Any]?) -> NetworkCompose.EndpointExpectation
    {
        let endpoint = EndpointExpectation(path: "/posts",
                                           method: .GET,
                                           queryParameters: ["postId": "1"],
                                           response: .successResponse(Post(userId: 1,
                                                                           id: 1,
                                                                           title: "Hoang")))
        return endpoint
    }
}
