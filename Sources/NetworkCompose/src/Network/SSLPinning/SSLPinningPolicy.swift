//
//  SSLPinningPolicy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 24/11/23.
//

import Foundation

public enum SSLPinningPolicy {
    /// SSL pinning is disabled.
    case disabled

    /// SSL pinning is enabled with a specific set of pinned certificates.
    ///
    /// - Parameter trust: An array of objects conforming to `SSLPinningInterface`, representing the certificates to be trusted.
    case trust([SSLPinningInterface])
}
