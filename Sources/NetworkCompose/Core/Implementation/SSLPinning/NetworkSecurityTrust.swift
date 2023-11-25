//
//  NetworkSecurityTrust.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

protocol NetworkSecurityTrust {
    var sslPinnings: [NetworkSSLPinning] { get }

    func verifyServerTrust(with protectionSpace: URLProtectionSpace) -> AuthChallengeDecision
}
