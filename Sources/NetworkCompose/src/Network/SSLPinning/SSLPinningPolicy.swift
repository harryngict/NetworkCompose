//
//  SSLPinningPolicy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public enum SSLPinningPolicy {
    case disabled
    case trust([SSLPinningInterface])
}
