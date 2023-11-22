//
//  NetworkKitFacade.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation

/// A facade class for handling network requests using `NetworkKitImp`.
///
/// This class provides a simplified interface for making network requests,
/// allowing both synchronous and asynchronous interactions.
///
/// ## Usage
/// ```swift
/// let service = NetworkKitFacade(baseURL: yourBaseURL)
///
/// // Asynchronous request
/// try await service.request(yourRequestType, andHeaders: yourHeaders)
///
/// // Synchronous request
/// service.request(yourRequestType, andHeaders: yourHeaders) { result in
///     switch result {
///     case let .success(response):
///         // Handle success
///     case let .failure(error):
///         // Handle error
///     }
/// }
/// ```
public final class NetworkKitFacade<SessionType: NetworkSession> {
    /// The underlying network kit responsible for handling requests.
    private let networkKit: NetworkKit

    /// Initializes the `NetworkKitFacade` with the specified configuration.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests. Defaults to `URLSession.shared`.
    public init(baseURL: URL,
                session: SessionType = URLSession.shared)
    {
        networkKit = NetworkKitImp(baseURL: baseURL, session: session)
    }

    /// Initializes the `NetworkKitFacade` with SSL pinning using a custom security trust.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - securityTrust: The security trust object for SSL pinning.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public init(baseURL: URL,
                securityTrust: NetworkSecurityTrust) throws
    {
        networkKit = try NetworkKitImp<URLSession>(baseURL: baseURL, securityTrust: securityTrust)
    }

    /// Initializes the `NetworkKitFacade` with a custom session delegate.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - sessionDelegate: The custom session delegate to handle various session events.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public init(baseURL: URL,
                sessionDelegate: URLSessionDelegate) throws
    {
        networkKit = try NetworkKitImp<URLSession>(baseURL: baseURL, sessionDelegate: sessionDelegate)
    }

    /// Performs an asynchronous network request using the async/await pattern.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    /// - Returns: The decoded success type from the response.
    /// - Throws: A `NetworkError` if the request fails.
    @available(iOS 15.0, *)
    public func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:]
    ) async throws -> RequestType.SuccessType {
        debugPrint(request.debugDescription)
        return try await networkKit.request(request, andHeaders: headers)
    }

    /// Performs a network request with a completion handler.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - completion: The completion handler to be called when the request is complete.
    public func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        debugPrint(request.debugDescription)
        networkKit.request(request, andHeaders: headers, completion: completion)
    }

    /// Initiates a network request to upload a file.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - fileURL: The URL of the file to be uploaded.
    ///   - completion: The completion handler to be called when the request is complete.
    public func uploadFile<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        fromFile fileURL: URL,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        debugPrint(request.debugDescription)
        networkKit.uploadFile(request, andHeaders: headers, fromFile: fileURL, completion: completion)
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
        debugPrint(request.debugDescription)
        networkKit.downloadFile(request, andHeaders: headers, completion: completion)
    }
}
