//
//  NetworkSecurityTrust.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

/// A protocol defining the interface for network security trust, with a focus on SSL pinning.
///
/// Conforming types are responsible for verifying server trust based on SSL pinning logic and making
/// authentication decisions during network requests.
protocol NetworkSecurityTrust {
    /// An array of SSL pinning hosts containing host names and associated pinning hashes.
    var sslPinnings: [NetworkSSLPinning] { get }

    /// Verifies server trust based on SSL pinning logic and makes an authentication decision.
    ///
    /// This method is responsible for evaluating the server trust based on the provided protection space,
    /// considering SSL pinning information, and determining the appropriate authentication decision.
    ///
    /// - Parameter protectionSpace: The protection space associated with the server trust challenge.
    /// - Returns: An `AuthChallengeDecision` indicating the decision based on server trust verification.
    func verifyServerTrust(with protectionSpace: URLProtectionSpace) -> AuthChallengeDecision
}
