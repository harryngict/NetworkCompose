//
//  AutomationMode.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

/// Enumeration defining strategies for mocking responses in automation tests.
public enum AutomationMode {
    /// Disables mocking for automation tests.
    case disabled

    /// Enables mocking for automation tests with the specified data type.
    /// - Parameter dataType: The type of data to use for mocking.
    case enabled(DataType)

    /// Enumeration defining data types for mocking responses in automation tests.
    public enum DataType {
        /// Specifies custom data for mocking, provided by an `EndpointExpectationProvider`.
        /// - Parameter expectationProvider: The provider for custom endpoint expectations.
        case custom(EndpointExpectationProvider)

        /// Uses locally stored data for mocking responses in automation tests.
        case local
    }
}
