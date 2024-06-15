//
//  MetricsCollector.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 23/11/23.
//

import Foundation

final class MetricsCollector: MetricsCollectorInterface {
  // MARK: Lifecycle

  init(metricInterceptor: MetricInterceptorInterface) {
    metricsExplorer = MetricsExplorer(metricInterceptor: metricInterceptor)
  }

  // MARK: Internal

  func taskCreated(_ task: URLSessionTask) {
    metricsExplorer.trackTaskCreated(task)
  }

  func taskDidCompleteWithError(_ task: URLSessionTask, error: Error?) {
    metricsExplorer.trackTaskDidCompleted(task, didCompleteWithError: error)
  }

  func taskDidFinishCollecting(_ task: URLSessionTask, metrics: URLSessionTaskMetrics) {
    metricsExplorer.trackTaskDidFinishCollecting(task, metrics: metrics)
  }

  // MARK: Private

  private let metricsExplorer: MetricsExplorer
}
