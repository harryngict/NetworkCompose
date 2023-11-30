//
//  ReportMetricStrategy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 27/11/23.
//

import Foundation

public enum ReportMetricStrategy {
    /// Disables reporting metrics for network operations.
    case disabled

    /// Enables reporting metrics for network operations using the specified metric interceptor.
    ///
    /// Use this strategy when you want to collect and report metrics during network operations. Provide a custom `MetricInterceptorInterface` to handle metric reporting.
    case enabled(MetricInterceptorInterface)
}
