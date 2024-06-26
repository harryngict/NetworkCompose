//
//  UniqueKey.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 26/11/23.
//

import Foundation
import NetworkCompose

// MARK: - UniqueKey

public struct UniqueKey {
  // MARK: Lifecycle

  /// Initializes a `UniqueKey` instance with the specified components.
  ///
  /// - Parameters:
  ///   - path: The path of the network request.
  ///   - method: The HTTP method of the network request.
  ///   - queryParameters: Optional query parameters for the network request. Default is `nil`.
  public init(path: String,
              method: NetworkMethod,
              queryParameters: [String: Any]? = nil)
  {
    var components: [String] = [method.rawValue, path]

    if let queryParameters {
      let query = queryParameters.sortedKeyValueString()
      components.append(query)
    }

    let value = components.joined(separator: "_")
    key = value.replacingOccurrences(of: "/", with: "_")
  }

  public init(
    request: some RequestInterface
  ) {
    self.init(
      path: request.path,
      method: request.method,
      queryParameters: request.queryParameters)
  }

  // MARK: Public

  public let key: String
}

// MARK: Hashable

extension UniqueKey: Hashable {
  /// Checks whether two `UniqueKey` instances are equal by comparing their keys.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side `UniqueKey`.
  ///   - rhs: The right-hand side `UniqueKey`.
  /// - Returns: `true` if the keys are equal; otherwise, `false`.
  public static func == (lhs: UniqueKey, rhs: UniqueKey) -> Bool {
    lhs.key == rhs.key
  }

  /// Hashes the `UniqueKey` instance using its key value.
  ///
  /// - Parameter hasher: The hasher to use for combining the hash values.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(key)
  }
}
