//
//  DefaultLogger.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 27/11/23.
//

import Foundation

public class DefaultLogger: LoggerInterface {
    public static let shared = DefaultLogger()

    private init() {}

    public func logInfo(_ level: LoggingLevel, _ message: String) {
        switch level {
        case .debug: debugPrint("ℹ️ NetworkCompose \(message)")
        case .error: debugPrint("🚫 NetworkCompose \(message)")
        }
    }
}
