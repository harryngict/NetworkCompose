//
//  NetworkKitMock.swift
//  NetworkSwift/CoreMocks
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation
import Network

public class NetworkKitMock: NetworkKit {
    public init() {}
    public init(networkReachability: NetworkReachability) {
        _networkReachability = networkReachability
    }

    public private(set) var requestCallCount = 0
    public var requestHandler: ((Any, [String: String], NetworkRetryPolicy) async throws -> (Any))?
    @available(iOS 15.0, *)
    public func request<RequestType: NetworkRequest>(_ request: RequestType, andHeaders headers: [String: String], retryPolicy: NetworkRetryPolicy) async throws -> RequestType.SuccessType {
        requestCallCount += 1
        if let requestHandler = requestHandler {
            return try await requestHandler(request, headers, retryPolicy) as! RequestType.SuccessType
        }
        fatalError("requestHandler returns can't have a default value thus its handler must be set")
    }

    public private(set) var requestAndHeadersCallCount = 0
    public var requestAndHeadersHandler: ((Any, [String: String], NetworkRetryPolicy, Any) -> Void)?
    public func request<RequestType: NetworkRequest>(_ request: RequestType, andHeaders headers: [String: String], retryPolicy: NetworkRetryPolicy, completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) {
        requestAndHeadersCallCount += 1
        if let requestAndHeadersHandler = requestAndHeadersHandler {
            requestAndHeadersHandler(request, headers, retryPolicy, completion)
        }
    }

    public private(set) var uploadFileCallCount = 0
    public var uploadFileHandler: ((Any, [String: String], URL, NetworkRetryPolicy, Any) -> Void)?
    public func uploadFile<RequestType: NetworkRequest>(_ request: RequestType, andHeaders headers: [String: String], fromFile fileURL: URL, retryPolicy: NetworkRetryPolicy, completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) {
        uploadFileCallCount += 1
        if let uploadFileHandler = uploadFileHandler {
            uploadFileHandler(request, headers, fileURL, retryPolicy, completion)
        }
    }

    public private(set) var downloadFileCallCount = 0
    public var downloadFileHandler: ((Any, [String: String], NetworkRetryPolicy, @escaping (Result<URL, NetworkError>) -> Void) -> Void)?
    public func downloadFile<RequestType: NetworkRequest>(_ request: RequestType, andHeaders headers: [String: String], retryPolicy: NetworkRetryPolicy, completion: @escaping (Result<URL, NetworkError>) -> Void) {
        downloadFileCallCount += 1
        if let downloadFileHandler = downloadFileHandler {
            downloadFileHandler(request, headers, retryPolicy, completion)
        }
    }

    public private(set) var networkReachabilitySetCallCount = 0
    private var _networkReachability: NetworkReachability! { didSet { networkReachabilitySetCallCount += 1 } }
    public var networkReachability: NetworkReachability {
        get { return _networkReachability }
        set { _networkReachability = newValue }
    }
}
