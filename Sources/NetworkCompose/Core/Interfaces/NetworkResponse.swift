//
//  NetworkResponse.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public protocol NetworkResponse {
    var statusCode: Int { get }
    var data: Data { get }
}
