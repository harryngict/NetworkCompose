//
//  SessionConfiguration.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

// TODO: Current we do not support background session.
// need to do in the future
public enum SessionConfigurationType {
    case `default`
    case ephemeral
}

public extension SessionConfigurationType {
    var sessionConfig: URLSessionConfiguration {
        switch self {
        case .ephemeral:
            let sessionConfig = URLSessionConfiguration.ephemeral
            sessionConfig.waitsForConnectivity = true
            sessionConfig.allowsCellularAccess = true
            sessionConfig.httpShouldUsePipelining = true
            sessionConfig.timeoutIntervalForRequest = 60.0
            sessionConfig.requestCachePolicy = .reloadRevalidatingCacheData
            sessionConfig.urlCache = URLCache.shared
            return sessionConfig
        case .default:
            return URLSessionConfiguration.default
        }
    }
}
