//
//  LoggingStrategy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 27/11/23.
//

import Foundation

public enum LoggingStrategy {
    case disabled
    case enabled
    case custom(LoggerInterface)
}
