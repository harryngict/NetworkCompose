//
//  DefaultLogger.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 27/11/23.
//

import Foundation

public class DefaultLogger: LoggerInterface {
  // MARK: Lifecycle

  private init() {}

  // MARK: Public

  public static let shared = DefaultLogger()

  public func log(_ type: LoggerType, _ message: String) {
    switch type {
    case .debug: debugPrint("🤖 \(LibraryConstant.domain) \(message)")
    case .error: debugPrint("🚫 \(LibraryConstant.domain) \(message)")
    }
  }
}
