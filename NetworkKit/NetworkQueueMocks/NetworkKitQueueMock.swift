//
//  NetworkKitQueueMock.swift
//  NetworkQueueMocks
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

public class NetworkKitQueueMock: NetworkKitQueue {
    public init() {}
    public init(reAuthService: ReAuthenticationService) {
        _reAuthService = reAuthService
    }

    public private(set) var reAuthServiceSetCallCount = 0
    private var _reAuthService: ReAuthenticationService! { didSet { reAuthServiceSetCallCount += 1 } }
    public var reAuthService: ReAuthenticationService {
        get { return _reAuthService }
        set { _reAuthService = newValue }
    }

    public private(set) var requestCallCount = 0
    public var requestHandler: ((Any, Any) -> Void)?
    public func request<RequestType: NetworkRequest>(_ request: RequestType, completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) {
        requestCallCount += 1
        if let requestHandler = requestHandler {
            requestHandler(request, completion)
        }
    }
}
