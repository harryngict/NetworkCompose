//
//  NetworkKitImpWrapper.swift
//  Core/Implementation
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation

public final class NetworkKitImpWrapper<SessionType: NetworkSession> {
    private let networkKit: NetworkKit

    public init(baseURL: URL,
                session: SessionType = URLSession.shared,
                credentialContainer: NetworkCredentialContainer? = nil)
    {
        networkKit = NetworkKitImp(baseURL: baseURL,
                                   session: session,
                                   credentialContainer: credentialContainer)
    }

    @available(iOS 15.0, *)
    public func request<RequestType: NetworkRequest>(
        _ request: RequestType
    ) async throws -> RequestType.SuccessType {
        debugPrint(request.debugDescription)
        return try await networkKit.request(request)
    }

    public func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        debugPrint(request.debugDescription)
        networkKit.request(request, completion: completion)
    }

    public func uploadFile<RequestType: NetworkRequest>(
        _ request: RequestType,
        fromFile fileURL: URL,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        debugPrint(request.debugDescription)
        networkKit.uploadFile(request, fromFile: fileURL, completion: completion)
    }

    public func downloadFile<RequestType: NetworkRequest>(
        _ request: RequestType,
        completion: @escaping (Result<URL, NetworkError>) -> Void
    ) {
        debugPrint(request.debugDescription)
        networkKit.downloadFile(request, completion: completion)
    }
}
