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

    public func log(_ type: LoggerType, _ message: String) {
        switch type {
        case .debug: debugPrint("🤖 \(LibraryConstant.domain) \(message)")
        case .error: debugPrint("🚫 \(LibraryConstant.domain) \(message)")
        }
    }
}
