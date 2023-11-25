//
//  NetworkExpectationProvider.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

/// A protocol that defines the expectations for network-related behavior.
public protocol NetworkExpectationProvider {
    /// An array of network expectations that the conforming type should fulfill.
    var networkExpectations: [NetworkExpectation] { get }
}
