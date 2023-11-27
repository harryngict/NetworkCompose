//
//  MetricInterceptorInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public protocol MetricInterceptorInterface {
    func sendEvent(_ event: TaskMetricEvent)
}
