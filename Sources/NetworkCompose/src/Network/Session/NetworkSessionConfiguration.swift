//
//  NetworkSessionConfiguration.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation
 
enum NetworkSessionConfiguration: Sendable {
    public static var `default`: URLSessionConfiguration {
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.waitsForConnectivity = true
        sessionConfig.allowsCellularAccess = true
        sessionConfig.httpShouldUsePipelining = true
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.requestCachePolicy = .reloadRevalidatingCacheData
        sessionConfig.urlCache = URLCache.shared
        return sessionConfig
    }
}
