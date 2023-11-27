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

    public func log(_ type: LoggingType, _ message: String) {
        switch type {
        case .debug: debugPrint("🤖 NetworkCompose \(message)")
        case .error: debugPrint("🚫 NetworkCompose \(message)")
        case .infor: debugPrint("🚀 NetworkCompose \(message)")
        }
    }
}
