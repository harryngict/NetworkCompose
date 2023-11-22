//
//  NetworkKitBuilder.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

import Foundation

/// A builder for constructing instances of `NetworkKitImp`.
///
/// Example usage:
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let networkKit = try? NetworkKitBuilder(baseURL: baseURL)
///     .setSecurityTrust(yourSecurityTrust)
///     .build()
/// ```
public class NetworkKitBuilder<SessionType: NetworkSession> {
    /// The base URL for network requests.
    private var baseURL: URL
    /// The network session to use for requests.
    private var session: SessionType
    /// The security trust object for SSL pinning.
    private var securityTrust: NetworkSecurityTrust?
    /// The custom session delegate to handle various session events.
    private var sessionDelegate: URLSessionDelegate?

    /// Initializes a `NetworkKitBuilder` with a base URL and a default session.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests.
    public init(baseURL: URL, session: SessionType = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }

    /// Sets the security trust for SSL pinning.
    ///
    /// - Parameter securityTrust: The security trust object for SSL pinning.
    /// - Returns: The builder instance for method chaining.
    public func setSecurityTrust(_ securityTrust: NetworkSecurityTrust) -> Self {
        self.securityTrust = securityTrust
        return self
    }

    /// Sets a custom session delegate.
    ///
    /// - Parameter sessionDelegate: The custom session delegate to handle various session events.
    /// - Returns: The builder instance for method chaining.
    public func setSessionDelegate(_ sessionDelegate: URLSessionDelegate) -> Self {
        self.sessionDelegate = sessionDelegate
        return self
    }

    /// Builds and returns a `NetworkKitImp` instance with the configured parameters.
    ///
    /// - Returns: A fully configured `NetworkKitImp` instance.
    /// - Throws: A `NetworkError` if the session cannot be created.
    public func build() throws -> NetworkKitImp<SessionType> {
        if let securityTrust = securityTrust {
            return try NetworkKitImp(
                baseURL: baseURL,
                session: createSessionWithSSLTrust(securityTrust)
            )
        } else if let sessionDelegate = sessionDelegate {
            return try NetworkKitImp(
                baseURL: baseURL,
                session: createSessionWithDelegate(sessionDelegate)
            )
        } else {
            return NetworkKitImp(baseURL: baseURL, session: session)
        }
    }

    private func createSessionWithSSLTrust(_ securityTrust: NetworkSecurityTrust) throws -> SessionType {
        let delegate = NetworkSessionTaskDelegate(securityTrust: securityTrust)
        guard let session = URLSession(
            configuration: NetworkSessionConfiguration.default,
            delegate: delegate,
            delegateQueue: OperationQueue.main
        ) as? SessionType else {
            throw NetworkError.invalidSession
        }
        return session
    }

    private func createSessionWithDelegate(_ sessionDelegate: URLSessionDelegate) throws -> SessionType {
        guard let session = URLSession(
            configuration: NetworkSessionConfiguration.default,
            delegate: sessionDelegate,
            delegateQueue: OperationQueue.main
        ) as? SessionType else {
            throw NetworkError.invalidSession
        }
        return session
    }
}
