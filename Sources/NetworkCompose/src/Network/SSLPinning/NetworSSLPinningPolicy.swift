//
//  NetworkSSLPinningPolicy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public enum NetworkSSLPinningPolicy {
    case ignore
    case trust([NetworkSSLPinning])

    var sslPinnings: [NetworkSSLPinning] {
        switch self {
        case .ignore: return []
        case let .trust(pinnings): return pinnings
        }
    }
}
