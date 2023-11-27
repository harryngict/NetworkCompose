//
//  SSLPinningPolicy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public enum SSLPinningPolicy {
    case trust([SSLPinningInterface])

    var sslPinnings: [SSLPinningInterface] {
        switch self {
        case let .trust(pinnings): return pinnings
        }
    }
}
