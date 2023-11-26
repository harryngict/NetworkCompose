//
//  SecurityTrust.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

protocol SecurityTrust {
    var sslPinnings: [SSLPinning] { get }

    func verifyServerTrust(with protectionSpace: URLProtectionSpace) -> AuthChallengeDecision
}
