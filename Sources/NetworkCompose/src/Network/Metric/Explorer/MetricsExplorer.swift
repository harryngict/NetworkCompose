//
//  MetricsExplorer.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

final class MetricsExplorer {
    private let metricInterceptor: MetricInterceptorInterface

    init(metricInterceptor: MetricInterceptorInterface) {
        self.metricInterceptor = metricInterceptor
    }

    func trackTaskCreated(_ task: URLSessionTask) {
        guard let originalRequest = task.originalRequest else {
            return
        }
        sendEvent(.created(TaskCreatedMetric(taskType: TaskType(task: task),
                                             createdAt: Date(),
                                             originalRequest: RequestMetric(originalRequest),
                                             currentRequest: task.currentRequest.map(RequestMetric.init))))
    }

    func trackTaskDidCompleted(_ task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let originalRequest = task.originalRequest else {
            return
        }
        sendEvent(.completed(TaskCompletedMetric(taskType: TaskType(task: task),
                                                 createdAt: Date(),
                                                 originalRequest: RequestMetric(originalRequest),
                                                 currentRequest: task.currentRequest.map(RequestMetric.init),
                                                 response: task.response.map(ResponseMetric.init),
                                                 error: error.map(ResponseErrorMetric.init),
                                                 requestBody: originalRequest.httpBody ?? originalRequest.httpBodyStreamData())))
    }

    func trackTaskDidUpdateProgress(_ task: URLSessionTask, didUpdateProgress progress: (completed: Int64, total: Int64)) {
        sendEvent(.progressUpdated(TaskProgressUpdatedMetric(taskType: TaskType(task: task),
                                                             createdAt: Date(),
                                                             url: task.originalRequest?.url,
                                                             completedUnitCount: progress.completed,
                                                             totalUnitCount: progress.total)))
    }

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

    private func sendEvent(_ event: TaskMetricEvent) {
        metricInterceptor.sendEvent(event)
    }
}
