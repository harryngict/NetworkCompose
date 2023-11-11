//
//  NetworkResponseImp.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

/// A structure representing the response received from a network request.
///
/// Use this structure to encapsulate the HTTP status code and data returned from a network operation.
///
/// Example usage:
/// ```swift
/// let response = NetworkResponseImp(statusCode: 200, data: responseData)
/// ```
struct NetworkResponseImp: NetworkResponse, Sendable {
    /// The HTTP status code of the response.
    let statusCode: Int
    /// The raw data received in the response.
    let data: Data

    /// Initializes a `NetworkResponseImp` instance with the specified status code and data.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code of the response.
    ///   - data: The raw data received in the response.
    init(statusCode: Int, data: Data) {
        self.statusCode = statusCode
        self.data = data
    }
}
