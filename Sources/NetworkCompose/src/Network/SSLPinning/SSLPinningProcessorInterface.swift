//
//  SSLPinningProcessorInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation

protocol SSLPinningProcessorInterface {
    var sslPinningPolicy: SSLPinningPolicy { get }
    func validateAuthentication(_ protectionSpace: URLProtectionSpace) -> AuthChallengeDecision
}
