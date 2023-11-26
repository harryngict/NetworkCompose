//
//  NetworkSecurityTrustImp.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

final class NetworkSecurityTrustImp: NetworkSecurityTrust {
    let sslPinnings: [NetworkSSLPinning]

    init(sslPinnings: [NetworkSSLPinning]) {
        self.sslPinnings = sslPinnings
    }

    func verifyServerTrust(with protectionSpace: URLProtectionSpace) -> AuthChallengeDecision {
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

        if let sslPinning = sslPinnings.first(where: { $0.host == protectionSpace.host }), sslPinning.hashKeys.contains(hash) {
            debugPrint("🤝 NetworkCompose trust: \(protectionSpace.host)")
            return AuthChallengeDecision(authChallengeDisposition: .useCredential,
                                         urlCredential: URLCredential(trust: serverTrust))
        } else {
            debugPrint("🚫 NetworkCompose doest not trust: \(protectionSpace.host)")
        }

        return AuthChallengeDecision(authChallengeDisposition: .cancelAuthenticationChallenge, urlCredential: nil)
    }
}
