//
//  CookieStorage.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 1/12/23.
//

import Foundation

// MARK: - CookieStorage

/// A protocol representing cookie storage.
/// @mockable
public protocol CookieStorage {
  var cookies: [HTTPCookie]? { get }

  func deleteCookie(_ cookie: HTTPCookie)
  func removeCookies(since date: Date)
  func cookies(for URL: URL) -> [HTTPCookie]?
  func addCookies(from response: HTTPURLResponse)
}

// MARK: - HTTPCookieStorage + CookieStorage

/// Extension to conform `HTTPCookieStorage` to `CookieStorage`.
extension HTTPCookieStorage: CookieStorage {
  public func addCookies(from response: HTTPURLResponse) {
    guard
      let url = response.url,
      let headers = response.allHeaderFields as? [String: String] else
    {
      return
    }
    let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
    setCookies(cookies, for: url, mainDocumentURL: nil)
  }
}
