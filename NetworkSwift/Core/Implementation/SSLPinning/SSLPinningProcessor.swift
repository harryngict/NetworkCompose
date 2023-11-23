//
//  SSLPinningProcessor.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation

/// A protocol defining the interface for SSL pinning processors.
protocol SSLPinningProcessor {
    /// Validates authentication challenges related to SSL pinning.
    /// - Parameter protectionSpace: The protection space associated with the authentication challenge.
    /// - Returns: An `AuthChallengeDecision` indicating the decision based on SSL pinning validation.
    func validateAuthentication(_ protectionSpace: URLProtectionSpace) -> AuthChallengeDecision
}
