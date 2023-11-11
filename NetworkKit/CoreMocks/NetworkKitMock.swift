//
//  NetworkKitMock.swift
//  CoreMocks
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

public class NetworkKitMock: NetworkKit {
    public init() {}

    public private(set) var requestCallCount = 0
    public var requestHandler: ((Any) async throws -> (Any))?

    @available(iOS 15.0, *)
    public func request<RequestType: NetworkRequest>(_ request: RequestType) async throws -> RequestType.SuccessType {
        requestCallCount += 1
        if let requestHandler = requestHandler {
            return try await requestHandler(request) as! RequestType.SuccessType
        }
        fatalError("requestHandler returns can't have a default value thus its handler must be set")
    }

    public private(set) var requestCompletionCallCount = 0
    public var requestCompletionHandler: ((Any, Any) -> Void)?
    public func request<RequestType: NetworkRequest>(_ request: RequestType, completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) {
        requestCompletionCallCount += 1
        if let requestCompletionHandler = requestCompletionHandler {
            requestCompletionHandler(request, completion)
        }
    }

    public private(set) var uploadFileCallCount = 0
    public var uploadFileHandler: ((Any, URL, Any) -> Void)?
    public func uploadFile<RequestType: NetworkRequest>(_ request: RequestType, fromFile fileURL: URL, completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void) {
        uploadFileCallCount += 1
        if let uploadFileHandler = uploadFileHandler {
            uploadFileHandler(request, fileURL, completion)
        }
    }

    public private(set) var downloadFileCallCount = 0
    public var downloadFileHandler: ((Any, @escaping (Result<URL, NetworkError>) -> Void) -> Void)?
    public func downloadFile<RequestType: NetworkRequest>(_ request: RequestType, completion: @escaping (Result<URL, NetworkError>) -> Void) {
        downloadFileCallCount += 1
        if let downloadFileHandler = downloadFileHandler {
            downloadFileHandler(request, completion)
        }
    }
}
