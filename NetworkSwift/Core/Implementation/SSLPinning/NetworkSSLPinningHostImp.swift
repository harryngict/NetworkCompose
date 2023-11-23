//
//  NetworkSSLPinningHostImp.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

/// A concrete implementation of `NetworkSSLPinningHost`.
public struct NetworkSSLPinningHostImp: NetworkSSLPinningHost, Sendable {
    /// The host name associated with the SSL pinning.
    public var host: String

    /// The SSL pinning hashes associated with the host.
    public var pinningHash: [String]

    /// Initializes a `NetworkSSLPinningHostImp` instance with the specified host and pinning hashes.
    ///
    /// - Parameters:
    ///   - host: The host name associated with the SSL pinning.
    ///   - pinningHash: The SSL pinning hashes associated with the host.
    public init(host: String, pinningHash: [String]) {
        self.host = host
        self.pinningHash = pinningHash
    }
}
