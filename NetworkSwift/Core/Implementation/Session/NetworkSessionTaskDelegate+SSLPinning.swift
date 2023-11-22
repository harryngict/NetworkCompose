//
//  NetworkSessionTaskDelegate+SSLPinning.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

/// A session delegate class responsible for handling authentication challenges, including SSL pinning.
open class NetworkSessionTaskDelegate: NSObject {
    private let sslPinningProcessor: SSLPinningProcessor

    /// Initializes the delegate with a specific SSL pinning processor.
    /// - Parameter sslPinningProcessor: The SSL pinning processor to be used for authentication challenges.
    public init(sslPinningProcessor: SSLPinningProcessor) {
        self.sslPinningProcessor = sslPinningProcessor
    }

    /// Convenience initializer to create a delegate with an SSL pinning processor based on network security trust.
    /// - Parameter securityTrust: The network security trust information used to create the SSL pinning processor.
    public convenience init(securityTrust: NetworkSecurityTrust) {
        let sslPinningProcessor = SSLPinningProcessorImp(securityTrust: securityTrust)
        self.init(sslPinningProcessor: sslPinningProcessor)
    }
}

// MARK: - URLSessionTaskDelegate

extension NetworkSessionTaskDelegate: URLSessionTaskDelegate {
    open func urlSession(_: URLSession,
                         didReceive challenge: URLAuthenticationChallenge,
                         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        let decision = sslPinningProcessor.validateAuthentication(challenge.protectionSpace)
        completionHandler(decision.authChallengeDisposition, decision.urlCredential)
    }
}
