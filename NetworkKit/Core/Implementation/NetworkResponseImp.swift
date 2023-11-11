//
//  NetworkResponseImp.swift
//  Core/Implementation
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public struct NetworkResponseImp: NetworkResponse {
    public let statusCode: Int
    public let data: Data

    public init(statusCode: Int, data: Data) {
        self.statusCode = statusCode
        self.data = data
    }
}
