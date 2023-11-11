//
//  NetworkSSLPinningImp.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

/// A concrete implementation of `NetworkSSLPinning`.
///
/// `NetworkSSLPinningImp` represents SSL pinning information for a specific host.
/// It includes the host name and a set of SSL pinning hashes associated with that host.
///
/// This struct conforms to the `NetworkSSLPinning` protocol and is also `Sendable`.
public struct NetworkSSLPinningImp: NetworkSSLPinning, Sendable {
    /// The host name associated with the SSL pinning.
    public var host: String

    /// The SSL pinning hashes associated with the host.
    public var hashKeys: Set<String>

    /// Initializes a `NetworkSSLPinningImp` instance with the specified host and pinning hashes.
    ///
    /// - Parameters:
    ///   - host: The host name associated with the SSL pinning.
    ///   - hashKeys: The SSL pinning hashes associated with the host.
    public init(host: String,
                hashKeys: Set<String>)
    {
        self.host = host
        self.hashKeys = hashKeys
    }
}
