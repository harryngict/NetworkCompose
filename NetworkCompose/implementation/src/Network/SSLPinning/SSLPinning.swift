//
//  SSLPinning.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 22/11/23.
//

import Foundation

public struct SSLPinning: SSLPinningInterface, Sendable {
  // MARK: Lifecycle

  public init(host: String,
              hashKeys: Set<String>)
  {
    self.host = host
    self.hashKeys = hashKeys
  }

  // MARK: Public

  public var host: String
  public var hashKeys: Set<String>
}
