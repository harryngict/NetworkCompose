//
//  NetworkKitBuilder.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 22/11/23.
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
public class NetworkKitBuilder<SessionType: NetworkSession> {
    /// The base URL for network requests.
    private let baseURL: URL

    /// The network session to use for requests.
    private var session: SessionType

    /// The security trust object for SSL pinning.
    private var securityTrust: NetworkSecurityTrust?

    /// The network reachability object for monitoring internet connection status.
    private var networkReachability: NetworkReachability

    /// Initializes a `NetworkKitBuilder` with a base URL and a default session.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    ///   - networkReachability: The network reachability object. Default is `NetworkReachabilityImp.shared`.
    public init(baseURL: URL,
                session: SessionType = URLSession.shared,
                networkReachability: NetworkReachability = NetworkReachabilityImp.shared)
    {
        self.baseURL = baseURL
        self.session = session
        self.networkReachability = networkReachability
    }

    /// Sets the security trust for SSL pinning.
    ///
    /// - Parameter securityTrust: The security trust object for SSL pinning.
    /// - Returns: The builder instance for method chaining.
    ///
    /// - Throws: A `NetworkError` if the session cannot be created.
    public func setSecurityTrust(_ securityTrust: NetworkSecurityTrust) throws -> Self {
        do {
            let delegate = NetworkSessionTaskDelegate(securityTrust: securityTrust)
            guard let session = URLSession(
                configuration: NetworkSessionConfiguration.default,
                delegate: delegate,
                delegateQueue: OperationQueue.main
            ) as? SessionType else {
                throw NetworkError.invalidSession
            }
            self.session = session
        } catch {
            throw NetworkError.invalidSession
        }
        return self
    }

    /// Builds and returns a `NetworkKitImp` instance with the configured parameters.
    ///
    /// - Returns: A fully configured `NetworkKitImp` instance.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public func build() -> NetworkKitImp<SessionType> {
        return NetworkKitImp(
            baseURL: baseURL,
            session: session,
            networkReachability: networkReachability
        )
    }
}
