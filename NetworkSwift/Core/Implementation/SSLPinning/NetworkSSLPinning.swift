//
//  NetworkSSLPinning.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

/// # Obtaining SSL PinningHash Hash Values
///
/// The `pinningHash` values in the `NetworkSSLPinning` class represent SHA-256 hashes of the public key pins used for SSL pinning. SSL pinning is a security feature that ensures your app communicates only with a server possessing a specific SSL/TLS certificate.
///
/// ## Steps to Obtain SSL PinningHash Hash Values
///
/// ### 1. Obtain the SSL/TLS Certificate
///
/// You can obtain the server's SSL/TLS certificate from the server itself or the certificate provider. If the server is publicly accessible, you can view the certificate details in a web browser.
///
/// ### 2. Extract the Public Key
///
/// Use OpenSSL or a similar tool to extract the public key from the certificate. Save the public key in a separate file.
///
/// ```bash
/// openssl x509 -pubkey -noout -in server_certificate.pem > public_key.pem
/// ```

/// A protocol representing a host with SSL pinning information.
public protocol NetworkSSLPinning {
    /// The host name associated with the SSL pinning.
    var host: String { get }

    /// The SSL pinning hashes associated with the host.
    var pinningHash: [String] { get }
}
