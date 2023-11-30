//
//  ResponseInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public protocol ResponseInterface {
    /// The  status code of the response.
    var statusCode: Int { get }

    /// The data received in the response.
    var data: Data { get }
}
