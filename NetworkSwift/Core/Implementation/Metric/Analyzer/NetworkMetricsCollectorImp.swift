//
//  NetworkMetricsCollectorImp.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A concrete implementation of `NetworkMetricsCollector` for tracking and analyzing network metrics.
final class NetworkMetricsCollectorImp: NetworkMetricsCollector {
    /// The analyzer responsible for processing and interpreting network metrics.
    private let metricsAnalyzer: NetworkMetricsAnalyzer

    /// Initializes a `NetworkMetricsCollectorImp` instance with the provided metric interceptor.
    ///
    /// - Parameter metricInterceptor: The interceptor for capturing network metrics.
    init(metricInterceptor: NetworkMetricInterceptor) {
        metricsAnalyzer = NetworkMetricsAnalyzer(metricInterceptor: metricInterceptor)
    }

    /// Informs the collector that a network task has been created.
    ///
    /// - Parameter task: The network task that was created.
    func taskCreated(_ task: URLSessionTask) {
        metricsAnalyzer.trackTaskCreated(task)
    }

    /// Informs the collector that a network task has completed with an error.
    ///
    /// - Parameters:
    ///   - task: The network task that completed.
    ///   - error: An optional error indicating how the task completed, or `nil` if the task was successful.
    func taskDidCompleteWithError(_ task: URLSessionTask, error: Error?) {
        metricsAnalyzer.trackTaskDidCompleteWithError(task, didCompleteWithError: error)
    }

    /// Informs the collector that a network task has updated its progress.
    ///
    /// - Parameters:
    ///   - task: The network task that updated its progress.
    ///   - progress: A tuple containing the completed and total bytes of the task.
    func taskDidUpdateProgress(_ task: URLSessionTask, progress: (completed: Int64, total: Int64)) {
        metricsAnalyzer.trackTaskDidUpdateProgress(task, didUpdateProgress: progress)
    }

    /// Informs the collector that a network task has finished collecting metrics.
    ///
    /// - Parameters:
    ///   - task: The network task that finished collecting metrics.
    ///   - metrics: The collected URLSessionTaskMetrics.
    func taskDidFinishCollecting(_ task: URLSessionTask, metrics: URLSessionTaskMetrics) {
        metricsAnalyzer.trackTaskDidFinishCollecting(task, metrics: metrics)
    }
}
