//
//  ClientRequest.swift
//  Example
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation
import NetworkKit

struct ClientRequest<T: Codable>: NetworkRequest {
    typealias SuccessType = T

    var path: String
    var method: NetworkMethod
    var queryParameters: [String: String]
    var headers: [String: String]
    var requiresCredentials: Bool

    init(path: String,
         method: NetworkMethod,
         queryParameters: [String: String] = [:],
         headers: [String: String] = [:],
         requiresCredentials: Bool = true)
    {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.headers = headers
        self.requiresCredentials = requiresCredentials
    }
}
