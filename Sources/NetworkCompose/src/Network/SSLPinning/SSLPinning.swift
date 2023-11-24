//
//  SSLPinning.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

public struct SSLPinning: SSLPinningInterface, Sendable {
    public var host: String
    public var hashKeys: Set<String>

    public init(host: String,
                hashKeys: Set<String>)
    {
        self.host = host
        self.hashKeys = hashKeys
    }
}
