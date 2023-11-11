//
//  LocalNetworkMetricInterceptor.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public struct LocalNetworkMetricInterceptor: NetworkMetricInterceptor {
    public init() {}

    public func sendEvent(_ event: NetworkTaskEvent) {
        var taskMetric: TaskMetric
        switch event {
        case let .taskCreated(metric):
            taskMetric = metric
        case let .taskProgressUpdated(metric):
            taskMetric = metric

        case let .taskCompleted(metric):
            taskMetric = metric

        case let .taskDidFinishCollecting(metric):
            taskMetric = metric
        }

        debugPrint(taskMetric)
    }
}
