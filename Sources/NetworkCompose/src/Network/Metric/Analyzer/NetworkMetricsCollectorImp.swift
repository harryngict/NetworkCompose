//
//  NetworkMetricsCollectorImp.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

final class NetworkMetricsCollectorImp: NetworkMetricsCollector {
    private let metricsAnalyzer: NetworkMetricsAnalyzer

    init(metricInterceptor: NetworkMetricInterceptor) {
        metricsAnalyzer = NetworkMetricsAnalyzer(metricInterceptor: metricInterceptor)
    }

    func taskCreated(_ task: URLSessionTask) {
        metricsAnalyzer.trackTaskCreated(task)
    }

    func taskDidCompleteWithError(_ task: URLSessionTask, error: Error?) {
        metricsAnalyzer.trackTaskDidCompleteWithError(task, didCompleteWithError: error)
    }

    func taskDidUpdateProgress(_ task: URLSessionTask, progress: (completed: Int64, total: Int64)) {
        metricsAnalyzer.trackTaskDidUpdateProgress(task, didUpdateProgress: progress)
    }

    func taskDidFinishCollecting(_ task: URLSessionTask, metrics: URLSessionTaskMetrics) {
        metricsAnalyzer.trackTaskDidFinishCollecting(task, metrics: metrics)
    }
}
