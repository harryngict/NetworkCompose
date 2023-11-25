//
//  NetworkMetricsAnalyzer.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// An analyzer responsible for processing and interpreting network metrics.
///
/// This class tracks the lifecycle of network tasks and generates relevant metrics for analysis.
final class NetworkMetricsAnalyzer {
    /// The interceptor for capturing network metrics.
    private let metricInterceptor: NetworkMetricInterceptor

    /// Initializes a `NetworkMetricsAnalyzer` instance with the provided metric interceptor.
    ///
    /// - Parameter metricInterceptor: The interceptor for capturing network metrics.
    init(metricInterceptor: NetworkMetricInterceptor) {
        self.metricInterceptor = metricInterceptor
    }

    /// Tracks the creation of a network task and generates a corresponding `TaskCreatedMetric`.
    ///
    /// - Parameter task: The network task that was created.
    func trackTaskCreated(_ task: URLSessionTask) {
        guard let originalRequest = task.originalRequest else {
            return
        }
        sendEvent(.created(TaskCreatedMetric(taskType: TaskType(task: task),
                                             createdAt: Date(),
                                             originalRequest: RequestMetric(originalRequest),
                                             currentRequest: task.currentRequest.map(RequestMetric.init))))
    }

    /// Tracks the completion of a network task with or without an error and generates a `TaskCompletedMetric`.
    ///
    /// - Parameters:
    ///   - task: The network task that completed.
    ///   - error: An optional error indicating how the task completed, or `nil` if the task was successful.
    func trackTaskDidCompleteWithError(_ task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let originalRequest = task.originalRequest else {
            return
        }
        sendEvent(.completed(TaskCompletedMetric(taskType: TaskType(task: task),
                                                 createdAt: Date(),
                                                 originalRequest: RequestMetric(originalRequest),
                                                 currentRequest: task.currentRequest.map(RequestMetric.init),
                                                 response: task.response.map(ResponseMetric.init),
                                                 error: error.map(ResponseErrorMetric.init),
                                                 requestBody: originalRequest.httpBody ?? originalRequest.httpBodyStreamData(),
                                                 responseBody: nil)))
    }

    /// Tracks the progress update of a network task and generates a `TaskProgressUpdatedMetric`.
    ///
    /// - Parameters:
    ///   - task: The network task that updated its progress.
    ///   - progress: A tuple containing the completed and total bytes of the task.
    func trackTaskDidUpdateProgress(_ task: URLSessionTask, didUpdateProgress progress: (completed: Int64, total: Int64)) {
        sendEvent(.progressUpdated(TaskProgressUpdatedMetric(taskType: TaskType(task: task),
                                                             createdAt: Date(),
                                                             url: task.originalRequest?.url,
                                                             completedUnitCount: progress.completed,
                                                             totalUnitCount: progress.total)))
    }

    /// Tracks the completion of collecting metrics for a network task and generates a `TaskDidFinishCollectingMetric`.
    ///
    /// - Parameters:
    ///   - task: The network task that finished collecting metrics.
    ///   - metrics: The collected URLSessionTaskMetrics.
    func trackTaskDidFinishCollecting(_ task: URLSessionTask, metrics: URLSessionTaskMetrics) {
        let statusCode = (metrics.transactionMetrics.first?.response as? HTTPURLResponse)?.statusCode ?? -1
        sendEvent(.didFinishCollecting(TaskDidFinishCollectingMetric(taskType: TaskType(task: task),
                                                                     createdAt: Date(),
                                                                     url: task.originalRequest?.url,
                                                                     taskInterval: metrics.taskInterval,
                                                                     countOfBytesReceived: task.countOfBytesReceived,
                                                                     countOfBytesSent: task.countOfBytesSent,
                                                                     statusCode: statusCode)))
    }

    /// Sends a network task event to the associated metric interceptor.
    ///
    /// - Parameter event: The network task event to be sent.
    private func sendEvent(_ event: NetworkTaskEvent) {
        metricInterceptor.sendEvent(event)
    }
}
