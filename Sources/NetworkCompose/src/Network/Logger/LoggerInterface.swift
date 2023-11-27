//
//  LoggerInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 27/11/23.
//

import Foundation

public enum LoggingLevel {
    case error
    case debug
}

public protocol LoggerInterface {
    func logInfo(_ level: LoggingLevel, _ message: String)
}
