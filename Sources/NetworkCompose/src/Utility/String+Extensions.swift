//
//  String+Extensions.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

public extension String {
    func extractHost() -> String? {
        guard let url = URL(string: self), let host = url.host else {
            return nil
        }
        return host
    }
}
