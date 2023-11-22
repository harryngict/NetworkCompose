//
//  NetworkKitImp.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

/// A class implementing the `NetworkKit` protocol that handles network requests.
///
/// Example usage:
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let networkKit = NetworkKitImp(baseURL: baseURL)
/// ```
public final class NetworkKitImp<SessionType: NetworkSession>: NetworkKit {
    /// The underlying network session responsible for handling requests.
    private let session: SessionType

    /// The base URL for network requests.
    private let baseURL: URL

    // MARK: Initializer

    /// Initializes the `NetworkKitImp` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    public init(baseURL: URL, session: SessionType = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }

    /// Convenience initializer for SSL pinning using a custom security trust.
    ///
    /// Use this initializer to create a `NetworkKitImp` instance with SSL pinning configured using a custom security trust.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - securityTrust: The security trust object for SSL pinning.
    ///   - configuration: The session configuration for the URL session. The default is `NetworkSessionConfiguration.default`.
    ///   - delegateQueue: The operation queue on which the delegate will receive URLSessionDelegate callbacks.
    ///                    The default value is the main operation queue.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public convenience init(baseURL: URL,
                            securityTrust: NetworkSecurityTrust,
                            configuration: URLSessionConfiguration = NetworkSessionConfiguration.default,
                            delegateQueue: OperationQueue? = OperationQueue.main) throws
    {
        let delegate = NetworkSessionTaskDelegate(securityTrust: securityTrust)
        guard let session = URLSession(configuration: configuration,
                                       delegate: delegate,
                                       delegateQueue: delegateQueue) as? SessionType
        else {
            throw NetworkError.invalidSession
        }
        self.init(baseURL: baseURL, session: session)
    }

    /// Creates a `NetworkKitImp` instance with a custom session delegate.
    ///
    /// Use this initializer to instantiate a `NetworkKitImp` object with a custom session delegate, allowing you to handle various session events.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - sessionDelegate: The custom session delegate to handle various session events.
    ///   - configuration: The session configuration for the URL session. The default is `NetworkSessionConfiguration.default`.
    ///   - delegateQueue: The operation queue on which the delegate will receive URLSessionDelegate callbacks. The default value is the main operation queue.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public convenience init(baseURL: URL,
                            sessionDelegate: URLSessionDelegate,
                            configuration: URLSessionConfiguration = NetworkSessionConfiguration.default,
                            delegateQueue: OperationQueue? = OperationQueue.main) throws
    {
        guard let session = URLSession(configuration: configuration,
                                       delegate: sessionDelegate,
                                       delegateQueue: delegateQueue) as? SessionType
        else {
            throw NetworkError.invalidSession
        }
        self.init(baseURL: baseURL, session: session)
    }

    // MARK: Request Handling

    /// Initiates a network request using the async/await pattern.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    /// - Returns: The decoded success type from the response.
    /// - Throws: A `NetworkError` if the request fails.
    @available(iOS 15.0, *)
    public func request<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:]
    ) async throws -> RequestType.SuccessType where RequestType: NetworkRequest {
        let networkRequest = try buildNetworkRequest(for: request, andHeaders: headers)
        let response = try await session.beginRequest(networkRequest)
        return try handleSuccessResponse(response, for: request)
    }

    /// Initiates a network request with a completion handler.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - completion: The completion handler to be called when the request is complete.
    public func request<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequest {
        do {
            let networkRequest = try buildNetworkRequest(for: request, andHeaders: headers)
            session.beginRequest(networkRequest) { result in
                self.handleResult(result, for: request, completion: completion)
            }
        } catch {
            completion(.failure(NetworkError.invalidSession))
        }
    }

    /// Initiates a network request to upload a file.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - fileURL: The URL of the file to be uploaded.
    ///   - completion: The completion handler to be called when the request is complete.
    public func uploadFile<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        fromFile fileURL: URL,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequest {
        do {
            var networkRequest = try buildNetworkRequest(for: request, andHeaders: headers)
            try session.beginUploadTask(&networkRequest, fromFile: fileURL) { result in
                self.handleResult(result, for: request, completion: completion)
            }
        } catch {
            completion(.failure(NetworkError.invalidSession))
        }
    }

    /// Initiates a network request to download a file.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - completion: The completion handler to be called when the request is complete.
    public func downloadFile<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        completion: @escaping (Result<URL, NetworkError>) -> Void
    ) {
        do {
            let networkRequest = try buildNetworkRequest(for: request, andHeaders: headers)
            session.beginDownloadTask(networkRequest, completion: completion)
        } catch {
            completion(.failure(NetworkError.invalidSession))
        }
    }

    // MARK: - Helper Methods

    private func buildNetworkRequest<RequestType: NetworkRequest>(
        for request: RequestType,
        andHeaders headers: [String: String]
    ) throws -> SessionType.NetworkRequestType {
        return try session.build(request, withBaseURL: baseURL, andHeaders: headers)
    }

    private func handleSuccessResponse<RequestType: NetworkRequest>(
        _ response: NetworkResponse,
        for request: RequestType
    ) throws -> RequestType.SuccessType {
        guard (200 ... 299).contains(response.statusCode) else {
            throw NetworkError.networkError(response.statusCode, nil)
        }
        return try request.responseDecoder.decode(RequestType.SuccessType.self, from: response.data)
    }

    private func handleResult<RequestType>(
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
                    completion(.failure(NetworkError.networkError(nil, error.localizedDescription)))
                }
            }
        case let .failure(error):
            completion(.failure(error))
        }
    }
}
