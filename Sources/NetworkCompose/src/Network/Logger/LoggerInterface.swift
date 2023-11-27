//
//  LoggerInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 27/11/23.
//

import Foundation

public enum LoggingType {
    case error
    case debug
    case infor
}

public protocol LoggerInterface {
    func log(_ type: LoggingType, _ message: String)
}
