//
//  NetworkExpectationProvider.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

public protocol NetworkExpectationProvider {
    var networkExpectations: [NetworkExpectation] { get }
}
