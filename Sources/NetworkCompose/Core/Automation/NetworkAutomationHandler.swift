//
//  NetworkAutomationHandler.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

final class NetworkAutomationHandler {
    var expectations: [NetworkExpectation] = []

    init(expectations: [NetworkExpectation] = []) {
        self.expectations = expectations
    }

    func addExpectations(_ expectations: [NetworkExpectation]) {
        self.expectations.append(contentsOf: expectations)
    }

    func getRequestResponse<RequestType>(
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: NetworkRequestInterface {
        guard let expectation = expectations.first(where: { $0.isSameRequest(request) }) else {
            throw NetworkError.invalidResponse
        }
        return try expectation.getResponse(request)
    }

    func getDownloadResponse<RequestType>(
        _ request: RequestType
    ) throws -> URL where RequestType: NetworkRequestInterface {
        guard let expectation = expectations.first(where: { $0.isSameRequest(request) }) else {
            throw NetworkError.invalidResponse
        }
        return try expectation.getDownloadResponse(request)
    }
}
