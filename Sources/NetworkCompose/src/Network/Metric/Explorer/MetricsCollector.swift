//
//  MetricsCollector.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

final class MetricsCollector: MetricsCollectorInterface {
    private let metricsExplorer: MetricsExplorer

    init(metricInterceptor: MetricInterceptorInterface) {
        metricsExplorer = MetricsExplorer(metricInterceptor: metricInterceptor)
    }

    func taskCreated(_ task: URLSessionTask) {
        metricsExplorer.trackTaskCreated(task)
    }

    func taskDidCompleteWithError(_ task: URLSessionTask, error: Error?) {
        metricsExplorer.trackTaskDidCompleteWithError(task, didCompleteWithError: error)
    }

    func taskDidUpdateProgress(_ task: URLSessionTask, progress: (completed: Int64, total: Int64)) {
        metricsExplorer.trackTaskDidUpdateProgress(task, didUpdateProgress: progress)
    }

    func taskDidFinishCollecting(_ task: URLSessionTask, metrics: URLSessionTaskMetrics) {
        metricsExplorer.trackTaskDidFinishCollecting(task, metrics: metrics)
    }
}
