//
//  NetworkAutomationHandler.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

/// A class responsible for handling network automation, providing mocked responses for network requests.
final class NetworkAutomationHandler {
    /// An array containing expectations with predefined responses.
    var expectations: [NetworkExpectation] = []

    /// Initializes an `ExpectationBuilder` instance.
    ///
    /// - Parameter expectations: An array of expectations with predefined responses.
    init(expectations: [NetworkExpectation] = []) {
        self.expectations = expectations
    }

    /// Adds a collection of expectations to the existing set.
    ///
    /// - Parameter expectations: The expectations to be added.
    func addExpectations(_ expectations: [NetworkExpectation]) {
        self.expectations.append(contentsOf: expectations)
    }

    /// Retrieves the mocked response for a network request.
    ///
    /// - Parameter request: The network request for which to retrieve the mocked response.
    /// - Returns: The mocked response.
    ///
    /// - Throws: A `NetworkError` if there is an issue retrieving the mocked response.
    func getRequestResponse<RequestType>(
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: NetworkRequestInterface {
        guard let expectation = expectations.first(where: { $0.isSameRequest(request) }) else {
            throw NetworkError.invalidResponse
        }
        return try expectation.getResponse(request)
    }

    /// Retrieves the mocked download response (URL) for a network request.
    ///
    /// - Parameter request: The network request for which to retrieve the mocked download response.
    /// - Returns: The mocked download response (URL).
    ///
    /// - Throws: A `NetworkError` if there is an issue retrieving the mocked download response.
    func getDownloadResponse<RequestType>(
        _ request: RequestType
    ) throws -> URL where RequestType: NetworkRequestInterface {
        guard let expectation = expectations.first(where: { $0.isSameRequest(request) }) else {
            throw NetworkError.invalidResponse
        }
        return try expectation.getDownloadResponse(request)
    }
}
