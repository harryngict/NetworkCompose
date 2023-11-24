//
//  NetworkResponseImp.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

struct NetworkResponseImp: NetworkResponse, Sendable {
    let statusCode: Int
    let data: Data

    init(statusCode: Int, data: Data) {
        self.statusCode = statusCode
        self.data = data
    }
}
