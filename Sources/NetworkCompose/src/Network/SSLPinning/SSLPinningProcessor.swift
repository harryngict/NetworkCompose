//
//  SSLPinningProcessor.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

final class SSLPinningProcessor: SSLPinningProcessorInterface {
    var sslPinningPolicy: SSLPinningPolicy
    private let loggerInterface: LoggerInterface?

    init(sslPinningPolicy: SSLPinningPolicy,
         loggerInterface: LoggerInterface?)
    {
        self.sslPinningPolicy = sslPinningPolicy
        self.loggerInterface = loggerInterface
    }

    func validateAuthentication(_ protectionSpace: URLProtectionSpace) -> AuthChallengeDecision {
        let isSecTrustValidationRequired = (protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)

        guard isSecTrustValidationRequired else {
            return AuthChallengeDecision(authChallengeDisposition: .performDefaultHandling, urlCredential: nil)
        }

        let decision = verifyServerTrust(with: protectionSpace)
        return decision
    }

    private func verifyServerTrust(with protectionSpace: URLProtectionSpace) -> AuthChallengeDecision {
        guard case let .trust(sslPinnings) = sslPinningPolicy else {
            return AuthChallengeDecision(authChallengeDisposition: .performDefaultHandling, urlCredential: nil)
        }

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

        let hash = serverKey.addRSAHeader()

        if let sslPinning = sslPinnings.first(where: { $0.host == protectionSpace.host }), sslPinning.hashKeys.contains(hash) {
            loggerInterface?.logInfo(.debug, "SSLPinningProcessor trust: \(protectionSpace.host)")
            return AuthChallengeDecision(authChallengeDisposition: .useCredential,
                                         urlCredential: URLCredential(trust: serverTrust))
        } else {
            loggerInterface?.logInfo(.error, "SSLPinningProcessor doest not trust: \(protectionSpace.host)")
        }

        return AuthChallengeDecision(authChallengeDisposition: .cancelAuthenticationChallenge, urlCredential: nil)
    }
}
