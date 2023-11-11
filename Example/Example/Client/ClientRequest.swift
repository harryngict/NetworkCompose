//
//  AppRequest.swift
//  Example
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation
import NetworkKit

struct ClientRequest: NetworkRequest {
    typealias SuccessType = ClientResponse
    var path: String
    var method: NetworkMethod
    var queryParameters: [String: String]
    var headers: [String: String]
    var requiresCredentials: Bool

    init(path: String = OnlineRemoteConfig.shared.apiConfig?.path ?? "",
         method: NetworkMethod = .GET,
         queryParameters: [String: String] = [:],
         headers: [String: String] = [:],
         requiresCredentials: Bool = false)
    {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.headers = headers
        self.requiresCredentials = requiresCredentials
    }
}
