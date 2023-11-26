//
//  SSLPinningProcessor.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation

protocol SSLPinningProcessor {
    var sslPinningPolicy: SSLPinningPolicy { get }
    func validateAuthentication(_ protectionSpace: URLProtectionSpace) -> AuthChallengeDecision
}
