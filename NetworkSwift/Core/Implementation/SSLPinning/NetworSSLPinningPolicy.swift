//
//  NetworkSSLPinningPolicy.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// Enum representing SSL pinning policies for network requests.
public enum NetworkSSLPinningPolicy {
    /// Ignore SSL pinning and trust any certificate.
    case ignore

    /// Trust specific certificates for SSL pinning.
    ///
    /// - Parameter pinningCertificates: An array of `NetworkSSLPinning` objects representing the certificates to trust.
    case trust([NetworkSSLPinning])
}
