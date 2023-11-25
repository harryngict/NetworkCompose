//
//  SSLPinningProcessorImp.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

final class SSLPinningProcessorImp: SSLPinningProcessor {
    private let securityTrust: NetworkSecurityTrust

    var sslPinningPolicy: NetworkSSLPinningPolicy

    init(sslPinningPolicy: NetworkSSLPinningPolicy,
         securityTrust: NetworkSecurityTrust)
    {
        self.sslPinningPolicy = sslPinningPolicy
        self.securityTrust = securityTrust
    }

    func validateAuthentication(_ protectionSpace: URLProtectionSpace) -> AuthChallengeDecision {
        let isSecTrustValidationRequired = (protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)

        guard isSecTrustValidationRequired else {
            return AuthChallengeDecision(authChallengeDisposition: .performDefaultHandling, urlCredential: nil)
        }

        let decision = securityTrust.verifyServerTrust(with: protectionSpace)
        return decision
    }
}
