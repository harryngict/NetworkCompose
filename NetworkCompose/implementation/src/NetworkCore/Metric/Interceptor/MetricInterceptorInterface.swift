//
//  MetricInterceptorInterface.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 23/11/23.
//

import Foundation

/// @mockable
public protocol MetricInterceptorInterface {
  /// Sends a task metric event to the interceptor.
  ///
  /// - Parameter event: The task metric event to be sent.
  func sendEvent(_ event: TaskMetricEvent)
}
