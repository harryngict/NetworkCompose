//
//  MetricInterceptor.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public protocol MetricInterceptor {
    func sendEvent(_ event: TaskMetricEvent)
}
