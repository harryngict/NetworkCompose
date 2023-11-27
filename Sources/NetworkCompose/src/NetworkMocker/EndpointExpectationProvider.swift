//
//  EndpointExpectationProvider.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

public protocol EndpointExpectationProvider {
    func expectation(for path: String, method: NetworkMethod) -> EndpointExpectation
}
