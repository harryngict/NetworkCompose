//
//  ResponseMetric.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 23/11/23.
//

import Foundation

public struct ResponseMetric: Hashable, Codable, Sendable {
  // MARK: Lifecycle

  public init(_ urlResponse: URLResponse) {
    let httpResponse = urlResponse as? HTTPURLResponse
    statusCode = httpResponse?.statusCode
    headers = httpResponse?.allHeaderFields as? [String: String]
  }

  // MARK: Public

  public var statusCode: Int?
  public var headers: [String: String]?

  public var contentType: ContentTypeMetric? {
    headers?["Content-Type"].flatMap(ContentTypeMetric.init)
  }

  public var isSuccess: Bool {
    guard let statusCode, (200 ... 299).contains(statusCode) else {
      return false
    }
    return true
  }
}
