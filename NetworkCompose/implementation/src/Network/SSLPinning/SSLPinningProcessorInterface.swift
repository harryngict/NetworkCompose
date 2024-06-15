//
//  SSLPinningProcessorInterface.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 19/11/23.
//

import Foundation

protocol SSLPinningProcessorInterface {
  /// SSL pinning policy associated with the processor.
  var sslPinningPolicy: SSLPinningPolicy { get }

  /// Validates authentication challenges for the given protection space.
  ///
  /// - Parameter protectionSpace: The protection space for which authentication is validated.
  /// - Returns: Authentication decision (accept or reject).
  func validateAuthentication(_ protectionSpace: URLProtectionSpace) -> AuthChallengeDecision
}
