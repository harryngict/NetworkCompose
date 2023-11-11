//
//  NetworkSecurityTrustImp.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

/// A class responsible for verifying server trust based on SSL pinning information.
public final class NetworkSecurityTrustImp: NetworkSecurityTrust {
    /// An array of SSL pinning hosts containing host names and associated pinning hashes.
    public let sslPinningHosts: [NetworkSSLPinningHost]

    /// Initializes a `NetworkSecurityTrustImp` instance with SSL pinning hosts.
    ///
    /// - Parameter sslPinningHosts: An array of `NetworkSSLPinningHost` objects representing SSL pinning information.
    public init(sslPinningHosts: [NetworkSSLPinningHost]) {
        self.sslPinningHosts = sslPinningHosts
    }

    /// Verifies server trust based on the provided protection space.
    ///
    /// - Parameter protectionSpace: The URL protection space associated with the authentication challenge.
    /// - Returns: An `AuthChallengeDecision` indicating how to handle the authentication challenge.
    public func verifyServerTrust(with protectionSpace: URLProtectionSpace) -> AuthChallengeDecision {
        guard let serverTrust: SecTrust = protectionSpace.serverTrust else {
            return AuthChallengeDecision(authChallengeDisposition: .performDefaultHandling,
                                         urlCredential: nil)
        }

        let policies: [SecPolicy] = [SecPolicyCreateSSL(true, protectionSpace.host as CFString?)]
        SecTrustSetPolicies(serverTrust, policies as CFTypeRef)

        var result = SecTrustResultType.invalid
        SecTrustEvaluate(serverTrust, &result)

        guard SecTrustGetCertificateCount(serverTrust) > 0 else {
            return AuthChallengeDecision(authChallengeDisposition: .cancelAuthenticationChallenge,
                                         urlCredential: nil)
        }

        guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return AuthChallengeDecision(authChallengeDisposition: .cancelAuthenticationChallenge,
                                         urlCredential: nil)
        }

        guard let serverKey = certificate.publicKey?.publicKeyData else {
            return AuthChallengeDecision(authChallengeDisposition: .cancelAuthenticationChallenge,
                                         urlCredential: nil)
        }

        let hash = serverKey.addRSAHeaderBase64EncodedString()

        if let host = sslPinningHosts.first(where: { $0.host == protectionSpace.host }), host.pinningHash.contains(hash) {
            return AuthChallengeDecision(authChallengeDisposition: .useCredential,
                                         urlCredential: URLCredential(trust: serverTrust))
        }

        return AuthChallengeDecision(authChallengeDisposition: .cancelAuthenticationChallenge, urlCredential: nil)
    }
}
