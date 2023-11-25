//
//  NetworkResponse.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public protocol NetworkResponse {
    /// HTTP status code of the response.
    var statusCode: Int { get }

    /// Data associated with the response.
    var data: Data { get }
}
