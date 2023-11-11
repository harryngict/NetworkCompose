//
//  NetworkKitMock.swift
//  NetworkSwift/CoreMocks
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

public class NetworkKitMock: NetworkKit {
    public init() {}

    public private(set) var requestCallCount = 0
    public var requestHandler: ((Any, [String: String]) async throws -> (Any))?

    @available(iOS 15.0, *)
    public func request<RequestType: NetworkRequest>(_ request: RequestType, andHeaders headers: [String: String]) async throws -> RequestType.SuccessType {
        requestCallCount += 1
        if let requestHandler = requestHandler {
            return try await requestHandler(request, headers) as! RequestType.SuccessType
        }
        fatalError("requestHandler returns can't have a default value thus its handler must be set")
    }

    public private(set) var requestAndHeadersCallCount = 0
    public var requestAndHeadersHandler: ((Any, [String: String], Any) -> Void)?
    public func request<RequestType: NetworkRequest>(_ request: RequestType, andHeaders headers: [String: String], completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) {
        requestAndHeadersCallCount += 1
        if let requestAndHeadersHandler = requestAndHeadersHandler {
            requestAndHeadersHandler(request, headers, completion)
        }
    }

    public private(set) var uploadFileCallCount = 0
    public var uploadFileHandler: ((Any, [String: String], URL, Any) -> Void)?
    public func uploadFile<RequestType: NetworkRequest>(_ request: RequestType, andHeaders headers: [String: String], fromFile fileURL: URL, completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) {
        uploadFileCallCount += 1
        if let uploadFileHandler = uploadFileHandler {
            uploadFileHandler(request, headers, fileURL, completion)
        }
    }

    public private(set) var downloadFileCallCount = 0
    public var downloadFileHandler: ((Any, [String: String], @escaping (Result<URL, NetworkError>) -> Void) -> Void)?
    public func downloadFile<RequestType: NetworkRequest>(_ request: RequestType, andHeaders headers: [String: String], completion: @escaping (Result<URL, NetworkError>) -> Void) {
        downloadFileCallCount += 1
        if let downloadFileHandler = downloadFileHandler {
            downloadFileHandler(request, headers, completion)
        }
    }
}
