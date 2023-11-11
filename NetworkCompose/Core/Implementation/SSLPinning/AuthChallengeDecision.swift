//
//  AuthChallengeDecision.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

/// A struct representing a decision related to URL authentication challenges.
struct AuthChallengeDecision {
    /// The disposition of the URL authentication challenge.
    let authChallengeDisposition: URLSession.AuthChallengeDisposition

    /// The URL credential associated with the decision. It can be `nil` if no credential is provided.
    let urlCredential: URLCredential?
}
