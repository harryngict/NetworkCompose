//
//  AuthChallengeDecision.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

struct AuthChallengeDecision {
    let authChallengeDisposition: URLSession.AuthChallengeDisposition
    let urlCredential: URLCredential?
}
