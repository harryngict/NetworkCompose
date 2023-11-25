//
//  NetworkStrategy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

/// An enumeration representing different strategies for handling network requests.
public enum NetworkStrategy {
    /// A strategy using network automation with predefined expectations.
    ///
    /// Use this strategy when you want to simulate network responses based on predefined expectations.
    ///
    /// - Parameter expectations: The expectations for mocking network responses.
    case mocker(NetworkExpectationProvider)

    /// A strategy indicating that requests should be sent to the actual server.
    ///
    /// Use this strategy when you want to make actual network requests to the server.
    case server
}
