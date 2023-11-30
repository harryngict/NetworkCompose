//
//  MetricInterceptorInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public protocol MetricInterceptorInterface {
    /// Sends a task metric event to the interceptor.
    ///
    /// - Parameter event: The task metric event to be sent.
    func sendEvent(_ event: TaskMetricEvent)
}
