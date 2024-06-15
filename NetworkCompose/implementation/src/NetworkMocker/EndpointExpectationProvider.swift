//
//  EndpointExpectationProvider.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 25/11/23.
//

import Foundation
import NetworkCompose

/// @mockable
public protocol EndpointExpectationProvider {
  /// Generates an expectation for a network endpoint.
  ///
  /// - Parameters:
  ///   - path: The endpoint path.
  ///   - method: The HTTP method (e.g., GET, POST).
  ///   - queryParameters: Optional query parameters.
  /// - Returns: An `EndpointExpectation` for the specified endpoint.
  func expectation(for path: String,
                   method: NetworkMethod,
                   queryParameters: [String: Any]?) -> EndpointExpectation
}
