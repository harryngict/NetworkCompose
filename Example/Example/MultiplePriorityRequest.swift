//
//  MultiplePriorityRequest.swift
//  Example
//
//  Created by Hoang Nguyezn on 28/11/23.
//

import Foundation
import NetworkCompose

final class MultiplePriorityRequest {
    static let shared = MultiplePriorityRequest()

    private let baseURL: URL

    private init() {
        baseURL = URL(string: "https://jsonplaceholder.typicode.com")!
    }

    func makeRequest(
        for scenario: DemoScenario,
        completion: @escaping (Result<[Post], NetworkError>) -> Void
    ) {
        switch scenario {
        case .multipleRequetWithPriority:
            performMultipleRequestsWithPriority(completion: completion)

        default: break
        }
    }

    private func performMultipleRequestsWithPriority(completion: @escaping (Result<[Post], NetworkError>) -> Void) {
        let request1 = RequestBuilder<[Comment]>(path: "/posts/1/comments", method: .GET).build()
        let request2 = RequestBuilder<[Photo]>(path: "/albums/1/photos", method: .GET).build()
        let request3 = RequestBuilder<[Post]>(path: "/users/1/albums", method: .GET).build()

        let retryPolicy: RetryPolicy = .constant(count: 3, delay: 5.0)

        var receivePosts: [Post] = []

        let network: NetworkPriorityDispatcher<URLSession> = NetworkPriorityDispatcher(baseURL: baseURL)
        network
            .logger(.enabled)
            .addRequest(request1, retryPolicy: retryPolicy, priority: .medium) { result in
                switch result {
                case .failure: debugPrint("Request1 error")
                case .success: debugPrint("Request1 success")
                }
            }
            .addRequest(request2, retryPolicy: retryPolicy, priority: .high) { result in
                switch result {
                case .failure: debugPrint("Request2 error)")
                case .success: debugPrint("Request2 success")
                }
            }
            .addRequest(request3, retryPolicy: retryPolicy, priority: .low) { result in
                switch result {
                case .failure: debugPrint("Request3 error")
                case let .success(posts):
                    receivePosts = posts
                    debugPrint("Request3 success")
                }
            }.execute {
                completion(.success(receivePosts))
                print("Completed all request here")
            }
    }
}
