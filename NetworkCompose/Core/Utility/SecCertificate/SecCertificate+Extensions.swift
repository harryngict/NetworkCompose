//
//  SecCertificate+Extensions.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

/// Extension on `SecCertificate` to extract the public key.
extension SecCertificate {
    /// Retrieves the public key from the certificate.
    var publicKey: SecKey? {
        let secPolicy = SecPolicyCreateBasicX509()

        var secTrust: SecTrust?
        guard SecTrustCreateWithCertificates(self, secPolicy, &secTrust) == errSecSuccess,
              let trust = secTrust
        else {
            return nil
        }

        var result: SecTrustResultType = .unspecified
        guard SecTrustEvaluate(trust, &result) == errSecSuccess else {
            return nil
        }

        return SecTrustCopyPublicKey(trust)
    }
}

/// Extension on `SecKey` to retrieve public key data.
extension SecKey {
    /// Retrieves the public key data from the key.
    var publicKeyData: Data? {
        guard let pubAttributes = SecKeyCopyAttributes(self) as? [String: Any],
              pubAttributes[String(kSecAttrKeyType)] as? String == String(kSecAttrKeyTypeRSA),
              pubAttributes[String(kSecAttrKeyClass)] as? String == String(kSecAttrKeyClassPublic),
              let data = pubAttributes[kSecValueData as String] as? Data
        else {
            return nil
        }

        return data
    }
}
