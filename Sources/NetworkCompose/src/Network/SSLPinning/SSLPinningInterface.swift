//
//  SSLPinningInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

public protocol SSLPinningInterface {
    /// The host for which SSL pinning is configured.
    var host: String { get }

    /// A set of hash keys representing the expected SSL certificate fingerprints for pinning.
    ///
    /// The SSL pinning mechanism checks the server's SSL certificate against these hash keys for verification.
    var hashKeys: Set<String> { get }
}
