//
//  NetworkSSLPinningPolicy.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// Enum representing SSL pinning policies for network requests.
///
/// SSL pinning is a security feature that helps prevent man-in-the-middle attacks by ensuring that
/// the server's certificate matches the expected certificate(s).
public enum NetworkSSLPinningPolicy {
    /// Ignore SSL pinning and trust any certificate.
    case ignore

    /// Trust specific certificates for SSL pinning.
    ///
    /// When using this policy, provide an array of `NetworkSSLPinning` objects representing the
    /// certificates to trust using the `.trust` case.
    ///
    /// - Parameter pinningCertificates: An array of `NetworkSSLPinning` objects representing the certificates to trust.
    case trust([NetworkSSLPinning])

    /// Get the array of `NetworkSSLPinning` objects based on the SSL pinning policy.
    var sslPinnings: [NetworkSSLPinning] {
        switch self {
        case .ignore: return []
        case let .trust(pinnings): return pinnings
        }
    }
}
