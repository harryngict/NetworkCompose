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
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    public init(baseURL: URL,
                session: SessionType = URLSession.shared,
                networkReachability: NetworkReachability = NetworkReachabilityImp.shared,
                executeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.executeQueue,
                observeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.observeQueue)
    {
        networkKit = NetworkKitImp(baseURL: baseURL,
                                   session: session,
                                   networkReachability: networkReachability,
                                   executeQueue: executeQueue,
                                   observeQueue: observeQueue)
    }

    /// Initializes the `NetworkKitFacade` with SSL pinning using a custom security trust.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - securityTrust: The security trust object for SSL pinning.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public init(baseURL: URL,
                securityTrust: NetworkSecurityTrust,
                networkReachability: NetworkReachability = NetworkReachabilityImp.shared,
                executeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.executeQueue,
                observeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.observeQueue) throws
    {
        networkKit = try NetworkKitBuilder(baseURL: baseURL, networkReachability: networkReachability)
            .setSecurityTrust(securityTrust)
            .setExecuteQueue(executeQueue)
            .setObserveQueue(observeQueue)
            .build()
    }

    /// Performs an asynchronous network request using the async/await pattern.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - retryPolicy: The retry policy for the network request.
    /// - Returns: The decoded success type from the response.
    /// - Throws: A `NetworkError` if the request fails.
    @available(iOS 15.0, *)
    public func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none
    ) async throws -> RequestType.SuccessType {
        return try await networkKit.request(request,
                                            andHeaders: headers,
                                            retryPolicy: retryPolicy)
    }

    /// Performs a network request with a completion handler.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called when the request is complete.
    public func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        networkKit.request(request,
                           andHeaders: headers,
                           retryPolicy: retryPolicy,
                           completion: completion)
    }

    /// Initiates a network request to upload a file.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - fileURL: The URL of the file to be uploaded.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called when the request is complete.
    public func uploadFile<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        fromFile fileURL: URL,
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) {
        networkKit.uploadFile(request,
                              andHeaders: headers,
                              fromFile: fileURL,
                              retryPolicy: retryPolicy,
                              completion: completion)
    }

    /// Initiates a network request to download a file.
    ///
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called when the request is complete.
    public func downloadFile<RequestType: NetworkRequest>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<URL, NetworkError>) -> Void
    ) {
        networkKit.downloadFile(request, andHeaders: headers,
                                retryPolicy: retryPolicy,
                                completion: completion)
    }
}
