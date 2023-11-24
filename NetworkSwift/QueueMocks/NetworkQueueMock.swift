//
//  NetworkQueueMock.swift
//  NetworkSwift/QueueMocks
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

public class NetworkQueueMock: NetworkQueue {
    public init() {}
    public init(reAuthService: ReAuthenticationService? = nil) {
        self.reAuthService = reAuthService
    }

    public private(set) var reAuthServiceSetCallCount = 0
    public var reAuthService: ReAuthenticationService? = nil { didSet { reAuthServiceSetCallCount += 1 } }

    public private(set) var requestCallCount = 0
    public var requestHandler: ((Any, [String: String], NetworkRetryPolicy, Any) -> Void)?
    public func request<RequestType: NetworkRequestInterface>(_ request: RequestType, andHeaders headers: [String: String], retryPolicy: NetworkRetryPolicy, completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) {
        requestCallCount += 1
        if let requestHandler = requestHandler {
            requestHandler(request, headers, retryPolicy, completion)
        }
    }
}
