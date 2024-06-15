//
//  RequestMetric.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 23/11/23.
//

import Foundation

public struct RequestMetric: Codable, Sendable {
  // MARK: Lifecycle

  public init(_ urlRequest: URLRequest) {
    url = urlRequest.url
    headers = urlRequest.allHTTPHeaderFields
    httpMethod = urlRequest.httpMethod
    rawCachePolicy = urlRequest.cachePolicy.rawValue
    timeout = urlRequest.timeoutInterval
  }

  // MARK: Public

  public var url: URL?
  public var httpMethod: String?
  public var headers: [String: String]?
  public var timeout: TimeInterval

  public var cachePolicy: URLRequest.CachePolicy {
    rawCachePolicy.flatMap(URLRequest.CachePolicy.init) ?? .useProtocolCachePolicy
  }

  public var contentType: ContentTypeMetric? {
    headers?["Content-Type"].flatMap(ContentTypeMetric.init)
  }

  // MARK: Private

  private var rawCachePolicy: UInt?
}
