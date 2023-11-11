//
//  ClientTrustSessionDelegate.swift
//  Example
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation

final class ClientTrustSessionDelegate: NSObject, URLSessionDelegate {
    /// Implement the URLSessionDelegate methods to handle SSL/TLS challenges
    func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge,

                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        /// You would typically implement proper certificate pinning logic here
        /// For simplicity, we are allowing any server trust in this example
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
}
