//
//  SessionConfigurationProvider.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

public protocol SessionConfigurationProvider {
    var sessionConfig: URLSessionConfiguration { get }
}

public enum DefaultSessionConfigurationProvider: SessionConfigurationProvider {
    case normal
    case background

    public var sessionConfig: URLSessionConfiguration {
        switch self {
        case .normal:
            let sessionConfig = URLSessionConfiguration.ephemeral
            sessionConfig.waitsForConnectivity = true
            sessionConfig.allowsCellularAccess = true
            sessionConfig.httpShouldUsePipelining = true
            sessionConfig.timeoutIntervalForRequest = 60.0
            sessionConfig.requestCachePolicy = .reloadRevalidatingCacheData
            sessionConfig.urlCache = URLCache.shared
            return sessionConfig
        case .background:
            let sessionConfig = URLSessionConfiguration.background(withIdentifier: "com.NetworkCompose.SessionConfiguration.background")
            sessionConfig.isDiscretionary = true
            sessionConfig.sessionSendsLaunchEvents = true
            return sessionConfig
        }
    }
}
