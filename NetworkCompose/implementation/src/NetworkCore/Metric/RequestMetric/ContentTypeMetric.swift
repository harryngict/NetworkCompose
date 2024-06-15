//
//  ContentTypeMetric.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 23/11/23.
//

import Foundation

public struct ContentTypeMetric: Hashable, ExpressibleByStringLiteral {
  // MARK: Lifecycle

  public init?(rawValue: String) {
    let parts = rawValue.split(separator: ";")
    guard let type = parts.first else { return nil }
    self.type = type.lowercased()
    var parameters: [String: String] = [:]
    for (key, value) in parts.dropFirst().compactMap(ContentTypeMetric.parseParameter) {
      parameters[key] = value
    }
    self.parameters = parameters
    self.rawValue = rawValue
  }

  public init(stringLiteral value: String) {
    self = ContentTypeMetric(rawValue: value) ?? .any
  }

  // MARK: Public

  public static let any = ContentTypeMetric(rawValue: "*/*")!

  public var type: String
  public var parameters: [String: String]
  public var rawValue: String

  public var isJSON: Bool { type.contains("json") }

  public var isPDF: Bool { type.contains("pdf") }

  public var isImage: Bool { type.hasPrefix("image/") }

  public var isHTML: Bool { type.contains("html") }

  public var isEncodedForm: Bool { type == "application/x-www-form-urlencoded" }

  // MARK: Private

  private static func parseParameter(_ param: Substring) -> (String, String)? {
    let parts = param.split(separator: "=")
    guard parts.count == 2, let name = parts.first, let value = parts.last else {
      return nil
    }
    return (name.trimmingCharacters(in: .whitespaces), value.trimmingCharacters(in: .whitespaces))
  }
}
