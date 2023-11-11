//
//  SSLPinningProcessorImp.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

/// SSLPinningProcessorImp is responsible for SSL pinning validation.
///
/// This class implements the SSLPinningProcessor protocol and provides methods
/// for validating server trust using SSL pinning.
public final class SSLPinningProcessorImp: SSLPinningProcessor {
    private let securityTrust: NetworkSecurityTrust

    /// Initializes an SSLPinningProcessorImp with the specified NetworkSecurityTrust object.
    ///
    /// - Parameter securityTrust: The NetworkSecurityTrust object used for SSL pinning validation.
    public init(securityTrust: NetworkSecurityTrust) {
        self.securityTrust = securityTrust
    }

    /// Validates authentication for the given URLProtectionSpace.
    ///
    /// This method is called when authentication is required, and it performs SSL pinning
    /// validation using the provided NetworkSecurityTrust object.
    ///
    /// - Parameter protectionSpace: The URLProtectionSpace for which authentication is required.
    /// - Returns: An AuthChallengeDecision indicating whether to perform default handling or
    ///            proceed with the provided decision.
    public func validateAuthentication(_ protectionSpace: URLProtectionSpace) -> AuthChallengeDecision {
        let isSecTrustValidationRequired = (protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)

        // Check if SSL pinning validation is required
        guard isSecTrustValidationRequired else {
            // If not required, perform default handling
            return AuthChallengeDecision(authChallengeDisposition: .performDefaultHandling, urlCredential: nil)
        }

        // Perform SSL pinning validation
        let decision = securityTrust.verifyServerTrust(with: protectionSpace)
        return decision
    }
}
