//
//  SSLPinning.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

public protocol SSLPinning {
    var host: String { get }
    var hashKeys: Set<String> { get }
}
