//
//  NetworkMetricInterceptor.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A protocol for objects that intercept and handle network metrics events.
public protocol NetworkMetricInterceptor {
    /// Notifies the interceptor about a network task event.
    ///
    /// - Parameter event: The network task event to be intercepted.
    func sendEvent(_ event: NetworkTaskEvent)
}
