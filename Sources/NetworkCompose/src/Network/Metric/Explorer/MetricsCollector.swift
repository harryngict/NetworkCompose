//
//  MetricsCollector.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 23/11/23.
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
        metricsExplorer.trackTaskDidCompleted(task, didCompleteWithError: error)
    }

    func taskDidUpdateProgress(_ task: URLSessionTask, progress: (completed: Int64, total: Int64)) {
        metricsExplorer.trackTaskDidUpdateProgress(task, didUpdateProgress: progress)
    }

    func taskDidFinishCollecting(_ task: URLSessionTask, metrics: URLSessionTaskMetrics) {
        metricsExplorer.trackTaskDidFinishCollecting(task, metrics: metrics)
    }

    func taskDidFinishDownloading(_ task: URLSessionDownloadTask) {
        metricsExplorer.trackTaskDidCompleted(task, didCompleteWithError: nil)
    }
}
