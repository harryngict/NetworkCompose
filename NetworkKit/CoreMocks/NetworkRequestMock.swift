//
//  NetworkRequestMock.swift
//  CoreMocks
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public struct NetworkRequestMock<T: Decodable>: NetworkRequest {
    public typealias SuccessType = T

    public var path: String

    public var method: NetworkMethod

    public var queryParameters: [String: String]

    public var headers: [String: String]

    public var body: Data?

    public var requiresCredentials: Bool

    public init(path: String = "",
                method: NetworkMethod = .GET,
                queryParameters: [String: String] = [:],
                headers: [String: String] = [:],
                body: Data? = nil,
                requiresCredentials: Bool = false)
    {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.headers = headers
        self.body = body
        self.requiresCredentials = requiresCredentials
    }
}
