//
//  LoggerStrategy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 27/11/23.
//

import Foundation

public enum LoggerStrategy {
    /// Disables logging for network operations.
    case disabled

    /// Enables default logging for network operations.
    case enabled

    /// Enables custom logging for network operations using the specified logger.
    ///
    /// Use this strategy when you want to customize the logging behavior during network operations. Provide a custom `LoggerInterface` to handle logging.
    case custom(LoggerInterface)
}
