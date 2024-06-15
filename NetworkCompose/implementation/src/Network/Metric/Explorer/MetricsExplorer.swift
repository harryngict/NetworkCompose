//
//  MetricsExplorer.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 24/11/23.
//

import Foundation

final class MetricsExplorer {
  // MARK: Lifecycle

  init(metricInterceptor: MetricInterceptorInterface) {
    self.metricInterceptor = metricInterceptor
  }

  // MARK: Internal

  func trackTaskCreated(_ task: URLSessionTask) {
    guard let originalRequest = task.originalRequest else {
      return
    }

    let metric = TaskCreatedMetric(
      taskType: TaskType(task: task),
      createdAt: Date(),
      originalRequest: RequestMetric(originalRequest),
      currentRequest: task.currentRequest.map(RequestMetric.init))
    let event = TaskMetricEvent.created(metric)

    sendEvent(event)
  }

  func trackTaskDidCompleted(_ task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let originalRequest = task.originalRequest else {
      return
    }

    let metric = TaskCompletedMetric(
      taskType: TaskType(task: task),
      createdAt: Date(),
      originalRequest: RequestMetric(originalRequest),
      currentRequest: task.currentRequest.map(RequestMetric.init),
      response: task.response.map(ResponseMetric.init),
      error: error.map(ResponseErrorMetric.init),
      requestBody: originalRequest.httpBody ?? httpBodyStreamData(originalRequest))

    let event = TaskMetricEvent.completed(metric)

    sendEvent(event)
  }

  func trackTaskDidUpdateProgress(_ task: URLSessionTask, didUpdateProgress progress: (completed: Int64, total: Int64)) {
    let metric = TaskProgressUpdatedMetric(
      taskType: TaskType(task: task),
      createdAt: Date(),
      url: task.originalRequest?.url,
      completedUnitCount: progress.completed,
      totalUnitCount: progress.total)
    let event = TaskMetricEvent.progressUpdated(metric)

    sendEvent(event)
  }

  func trackTaskDidFinishCollecting(_ task: URLSessionTask, metrics: URLSessionTaskMetrics) {
    let statusCode = (metrics.transactionMetrics.first?.response as? HTTPURLResponse)?.statusCode ?? -1

    let metric = TaskDidFinishCollectingMetric(
      taskType: TaskType(task: task),
      createdAt: Date(),
      url: task.originalRequest?.url,
      taskInterval: metrics.taskInterval,
      countOfBytesReceived: task.countOfBytesReceived,
      countOfBytesSent: task.countOfBytesSent,
      statusCode: statusCode)
    let event = TaskMetricEvent.didFinishCollecting(metric)

    sendEvent(event)
  }

  func httpBodyStreamData(_ request: URLRequest) -> Data? {
    guard let bodyStream = request.httpBodyStream else {
      return nil
    }

    let bufferSize = 1024
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    bodyStream.open()
    defer {
      buffer.deallocate()
      bodyStream.close()
    }

    var bodyStreamData = Data()
    while bodyStream.hasBytesAvailable {
      let readData = bodyStream.read(buffer, maxLength: bufferSize)
      bodyStreamData.append(buffer, count: readData)
    }
    return bodyStreamData
  }

  // MARK: Private

  private let metricInterceptor: MetricInterceptorInterface

  private func sendEvent(_ event: TaskMetricEvent) {
    metricInterceptor.sendEvent(event)
  }
}
