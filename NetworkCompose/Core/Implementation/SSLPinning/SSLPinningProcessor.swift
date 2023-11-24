//
//  SSLPinningProcessor.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation

/// A protocol defining the interface for SSL pinning processors.
///
/// Conforming types are responsible for handling SSL pinning challenges during network requests.
protocol SSLPinningProcessor {
    /// The SSL pinning policy to be used for validation.
    var sslPinningPolicy: NetworkSSLPinningPolicy { get }

    /// Validates authentication challenges related to SSL pinning.
    ///
    /// When an authentication challenge is encountered during a network request, this method is called
    /// to perform SSL pinning validation based on the provided protection space.
    ///
    /// - Parameter protectionSpace: The protection space associated with the authentication challenge.
    /// - Returns: An `AuthChallengeDecision` indicating the decision based on SSL pinning validation.
    func validateAuthentication(_ protectionSpace: URLProtectionSpace) -> AuthChallengeDecision
}
