//
//  MetricInterceptor.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 24/11/23.
//

import Foundation

public typealias MetricReportHandler = (_ event: TaskMetricEvent) -> Void

public struct MetricInterceptor: MetricInterceptorInterface {
    private let reportHandler: MetricReportHandler

    public init(reportHandler: @escaping MetricReportHandler) {
        self.reportHandler = reportHandler
    }

    public func sendEvent(_ event: TaskMetricEvent) {
        reportHandler(event)
    }
}
