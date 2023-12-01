//
//  CookieStorage.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 1/12/23.
//

import Foundation

/// A protocol representing cookie storage.
public protocol CookieStorage {
    var cookies: [HTTPCookie]? { get }

    func deleteCookie(_ cookie: HTTPCookie)
    func removeCookies(since date: Date)
    func cookies(for URL: URL) -> [HTTPCookie]?
    func addCookies(from response: HTTPURLResponse)
}

/// Extension to conform `HTTPCookieStorage` to `CookieStorage`.
extension HTTPCookieStorage: CookieStorage {
    public func addCookies(from response: HTTPURLResponse) {
        guard let url = response.url,
              let headers = response.allHeaderFields as? [String: String]
        else {
            return
        }
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
        setCookies(cookies, for: url, mainDocumentURL: nil)
    }
}
