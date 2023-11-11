//
//  NetworkResponseMock.swift
//  NetworkSwift/CoreMocks
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public class NetworkResponseMock: NetworkResponse {
    public var statusCode: Int
    public var data: Data

    public init(statusCode: Int, response: Encodable? = nil) {
        self.statusCode = statusCode
        if let response = response, let data = try? JSONEncoder().encode(response) {
            self.data = data
        } else {
            data = Data()
        }
    }
}
