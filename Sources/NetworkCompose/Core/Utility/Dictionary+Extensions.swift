//
//  Dictionary+Extensions.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    func urlEncodedQueryString() -> String {
        return map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}
