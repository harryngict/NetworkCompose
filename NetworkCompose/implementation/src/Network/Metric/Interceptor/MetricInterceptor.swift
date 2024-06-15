//
//  MetricInterceptor.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 24/11/23.
//

import Foundation

public typealias MetricReportHandler = (_ event: TaskMetricEvent) -> Void

// MARK: - MetricInterceptor

public struct MetricInterceptor: MetricInterceptorInterface {
  // MARK: Lifecycle

  public init(reportHandler: @escaping MetricReportHandler) {
    self.reportHandler = reportHandler
  }

  // MARK: Public

  public func sendEvent(_ event: TaskMetricEvent) {
    reportHandler(event)
  }

  // MARK: Private

  private let reportHandler: MetricReportHandler
}
