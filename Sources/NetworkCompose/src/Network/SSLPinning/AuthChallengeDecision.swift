//
//  AuthChallengeDecision.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 21/11/23.
//

import Foundation

struct AuthChallengeDecision {
    /// The disposition indicating how to respond to the authentication challenge.
    ///
    /// - SeeAlso: `URLSession.AuthChallengeDisposition`
    let authChallengeDisposition: URLSession.AuthChallengeDisposition

    /// The URL credential to be used for authentication, if applicable.
    ///
    /// If `authChallengeDisposition` is `.useCredential`, this property contains the credential to be used.
    let urlCredential: URLCredential?
}
