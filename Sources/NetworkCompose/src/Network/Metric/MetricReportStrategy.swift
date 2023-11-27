//
//  MetricTaskReportStrategy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 27/11/23.
//

import Foundation

public enum MetricTaskReportStrategy {
    case disabled
    case enabled(MetricInterceptorInterface)
}
