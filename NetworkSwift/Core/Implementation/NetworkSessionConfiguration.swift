//
//  NetworkSessionConfiguration.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 21/11/23.
//

import Foundation

/// Configuration options for a network session.
public enum NetworkSessionConfiguration {
    /// The default configuration for a network session.
    public static var `default`: URLSessionConfiguration {
        let sessionConfig = URLSessionConfiguration.ephemeral

        /// Enables waiting for connectivity before sending the request.
        sessionConfig.waitsForConnectivity = true

        /// Allows the session to use cellular data.
        sessionConfig.allowsCellularAccess = true

        /// Indicates whether the session should pipeline HTTP requests.
        sessionConfig.httpShouldUsePipelining = true

        /// The maximum amount of time that a resource request should be allowed to take.
        sessionConfig.timeoutIntervalForRequest = 60.0

        /// The cache policy for the session.
        sessionConfig.requestCachePolicy = .reloadRevalidatingCacheData

        /// The URL cache to be used by the session.
        sessionConfig.urlCache = URLCache.shared

        return sessionConfig
    }
}
