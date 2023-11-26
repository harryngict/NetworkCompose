//
//  SSLPinningPolicy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public enum SSLPinningPolicy {
    case ignore
    case trust([SSLPinningInterface])

    var sslPinnings: [SSLPinningInterface] {
        switch self {
        case .ignore: return []
        case let .trust(pinnings): return pinnings
        }
    }
}
