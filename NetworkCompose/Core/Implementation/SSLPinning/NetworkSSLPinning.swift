//
//  NetworkSSLPinning.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

public protocol NetworkSSLPinning {
    /// The host name associated with the SSL pinning.
    var host: String { get }

    /// The SSL pinning hashes associated with the host.
    var hashKeys: Set<String> { get }
}
