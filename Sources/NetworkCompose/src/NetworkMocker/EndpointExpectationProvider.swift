//
//  EndpointExpectationProvider.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

public protocol EndpointExpectationProvider {
    func getExpectaion(path: String, method: NetworkMethod) -> EndpointExpectation
}
