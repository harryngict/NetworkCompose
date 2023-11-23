//
//  NetworkKitBuilder.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// A builder for constructing instances of `NetworkKitImp`.
///
/// This builder provides a convenient way to create and configure a `NetworkKitImp` instance for making network requests.
///
/// ## Example Usage
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let networkKit = try? NetworkKitBuilder(baseURL: baseURL)
///     .setSecurityTrust(yourSecurityTrust)
///     .build()
/// ```
public class NetworkKitBuilder<SessionType: NetworkSession>: NetworkKitBuilderBase<SessionType> {
    /// Initializes a `NetworkKitBuilder` with a base URL and a default session.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    ///   - executeQueue: The dispatch queue for executing network requests.
    ///   - observeQueue: The dispatch queue for observing and handling network events.
    public required init(baseURL: URL,
                         session: SessionType = URLSession.shared,
                         networkReachability: NetworkReachability = NetworkReachabilityImp.shared,
                         executeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.executeQueue,
                         observeQueue: NetworkDispatchQueue = DefaultNetworkDispatchQueue.observeQueue)
    {
        super.init(baseURL: baseURL,
                   session: session,
                   networkReachability: networkReachability,
                   executeQueue: executeQueue,
                   observeQueue: observeQueue)
    }

    /// Builds and returns a `NetworkKitImp` instance with the configured parameters.
    ///
    /// - Returns: A fully configured `NetworkKitImp` instance.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public func build() -> NetworkKitImp<SessionType> {
        return NetworkKitImp(
            baseURL: baseURL,
            session: session,
            networkReachability: networkReachability,
            executeQueue: executeQueue,
            observeQueue: observeQueue
        )
    }

    /// Performs a network request with a completion handler.
    ///
    /// - Parameters:
    ///   - sendRequest: The network request to be executed.
    ///   - headers: Additional headers to include in the request.
    ///   - retryPolicy: The retry policy for the network request.
    ///   - completion: The completion handler to be called when the request is complete.
    public func sendRequest<RequestType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: NetworkRetryPolicy = .none,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) where RequestType: NetworkRequest {
        build().request(request, andHeaders: headers,
                        retryPolicy: retryPolicy,
                        completion: completion)
    }
}
