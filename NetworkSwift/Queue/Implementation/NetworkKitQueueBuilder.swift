//
//  NetworkKitQueueBuilder.swift
//  NetworkSwift/Queue
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

/// A builder for constructing instances of `NetworkKitQueueImp`.
///
/// Example usage:
/// ```swift
/// let baseURL = URL(string: "https://api.example.com")!
/// let networkKitQueue = NetworkKitQueueBuilder(baseURL: baseURL)
///     .setReAuthService(yourReAuthService)
///     .setSerialOperationQueue(yourOperationQueueManager)
///     .setSecurityTrust(yourSecurityTrust)
///     .build()
/// ```
public final class NetworkKitQueueBuilder<SessionType: NetworkSession> {
    /// The base URL for network requests.
    private var baseURL: URL

    /// The network session to use for requests.
    private var session: SessionType

    /// The service responsible for re-authentication if required.
    private var reAuthService: ReAuthenticationService?

    /// The operation queue manager used to serialize network operations.
    private var serialOperationQueue: OperationQueueManager

    /// Initializes a `NetworkKitQueueBuilder` with a base URL and a default session.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for network requests.
    ///   - session: The network session to use for requests. Defaults to `URLSession.shared`.
    public init(baseURL: URL,
                session: SessionType = URLSession.shared,
                serialOperationQueue: OperationQueueManager = OperationQueueManagerImp(maxConcurrentOperationCount: 1))
    {
        self.baseURL = baseURL
        self.session = session
        self.serialOperationQueue = serialOperationQueue
    }

    /// Sets the re-authentication service.
    ///
    /// - Parameter reAuthService: The service responsible for re-authentication.
    /// - Returns: The builder instance for method chaining.
    public func setReAuthService(_ reAuthService: ReAuthenticationService) -> Self {
        self.reAuthService = reAuthService
        return self
    }

    /// Sets the operation queue manager for serializing network operations.
    ///
    /// - Parameter serialOperationQueue: The operation queue manager.
    /// - Returns: The builder instance for method chaining.
    public func setSerialOperationQueue(_ serialOperationQueue: OperationQueueManager) -> Self {
        self.serialOperationQueue = serialOperationQueue
        return self
    }

    /// Builds and returns a `NetworkKitQueueImp` instance with the configured parameters.
    ///
    /// - Returns: A fully configured `NetworkKitQueueImp` instance.
    public func build() -> NetworkKitQueueImp<SessionType> {
        return NetworkKitQueueImp(
            baseURL: baseURL,
            session: session,
            reAuthService: reAuthService,
            serialOperationQueue: serialOperationQueue
        )
    }

    /// Sets the security trust for SSL pinning.
    ///
    /// - Parameter securityTrust: The security trust object for SSL pinning.
    /// - Throws: A `NetworkError` if the session cannot be created.
    /// - Returns: The builder instance for method chaining.
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

    /// Sets a custom session delegate.
    ///
    /// - Parameter sessionDelegate: The custom session delegate to handle various session events.
    /// - Throws: A `NetworkError` if the session cannot be created.
    /// - Returns: The builder instance for method chaining.
    public func setSessionDelegate(_ sessionDelegate: URLSessionDelegate) throws -> Self {
        do {
            guard let session = URLSession(
                configuration: NetworkSessionConfiguration.default,
                delegate: sessionDelegate,
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
}
