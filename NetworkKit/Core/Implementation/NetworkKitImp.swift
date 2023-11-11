//
//  NetworkKitImp.swift
//  Core/Implementation
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public final class NetworkKitImp<SessionType: NetworkSession>: NetworkKit {
    private let session: SessionType
    private let baseURL: URL
    private var credentialContainer: NetworkCredentialContainer?

    // MARK: Initializer

    public init(baseURL: URL,
                session: SessionType = URLSession.shared,
                credentialContainer: NetworkCredentialContainer? = nil)
    {
        self.baseURL = baseURL
        self.session = session
        self.credentialContainer = credentialContainer
    }

    // MARK: - Request Handling

    @available(iOS 15.0, *)
    public func request<RequestType>(
        _ request: RequestType
    ) async throws -> RequestType.SuccessType where RequestType: NetworkRequest {
        let networkRequest = try buildNetworkRequest(for: request)
        let response = try await session.beginRequest(networkRequest)
        return try handleSuccessResponse(response, for: request)
    }

    public func request<RequestType>(
        _ request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequest {
        do {
            let networkRequest = try buildNetworkRequest(for: request)
            session.beginRequest(networkRequest) { result in
                self.handleResult(result, for: request, completion: completion)
            }
        } catch {
            completion(.failure(NetworkError.invalidSession))
        }
    }

    public func uploadFile<RequestType>(
        _ request: RequestType,
        fromFile fileURL: URL,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequest {
        do {
            let networkRequest = try buildNetworkRequest(for: request)
            session.beginUploadTask(networkRequest, fromFile: fileURL) { result in
                self.handleResult(result, for: request, completion: completion)
            }
        } catch {
            completion(.failure(NetworkError.invalidSession))
        }
    }

    public func downloadFile<RequestType: NetworkRequest>(
        _ request: RequestType,
        completion: @escaping (Result<URL, NetworkError>) -> Void
    ) {
        do {
            let networkRequest = try buildNetworkRequest(for: request)
            session.beginDownloadTask(networkRequest, completion: completion)
        } catch {
            completion(.failure(NetworkError.invalidSession))
        }
    }
}

// MARK: - Helper Methods

private extension NetworkKitImp {
    func buildNetworkRequest<RequestType: NetworkRequest>(
        for request: RequestType
    ) throws -> SessionType.NetworkRequestType {
        let authHeaders = getAuthHeaders(withCredentials: credentialContainer)
        return try session.build(request, withBaseURL: baseURL, withAuthHeaders: authHeaders)
    }

    func getAuthHeaders(withCredentials credentialContainer: NetworkCredentialContainer?) -> [String: String] {
        return credentialContainer?.getCredentials() ?? [:]
    }

    func handleSuccessResponse<RequestType: NetworkRequest>(
        _ response: NetworkResponse,
        for request: RequestType
    ) throws -> RequestType.SuccessType {
        guard response.statusCode / 100 == 2 else {
            throw NetworkError.serviceError(response.statusCode, nil)
        }
        return try request.responseDecode.decode(RequestType.SuccessType.self, from: response.data)
    }

    func handleResult<RequestType>(
        _ result: Result<NetworkResponse, NetworkError>,
        for request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequest {
        switch result {
        case let .success(response):
            do {
                let decodedResponse = try handleSuccessResponse(response, for: request)
                completion(.success(decodedResponse))
            } catch {
                if let error = error as? NetworkError {
                    completion(.failure(error))
                } else {
                    completion(.failure(NetworkError.serviceError(nil, error.localizedDescription)))
                }
            }
        case let .failure(error):
            completion(.failure(error))
        }
    }
}
