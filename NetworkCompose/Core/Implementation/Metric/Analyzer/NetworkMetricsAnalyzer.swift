//
//  NetworkMetricsAnalyzer.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// An analyzer responsible for processing and interpreting network metrics.
///
/// This class tracks the lifecycle of network tasks and generates relevant metrics for analysis.
final class NetworkMetricsAnalyzer {
    /// Dictionary to store task contexts with their corresponding keys.
    private var tasks: [TaskKey: TaskContext] = [:]

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
        sendEvent(.taskCreated(TaskCreatedMetric(taskId: context(for: task).taskId,
                                                 taskType: TaskType(task: task),
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
        let context = self.context(for: task)
        tasks[TaskKey(task: task)] = nil
        let data = context.data
        sendEvent(.taskCompleted(TaskCompletedMetric(taskId: context.taskId,
                                                     taskType: TaskType(task: task),
                                                     createdAt: Date(),
                                                     originalRequest: RequestMetric(originalRequest),
                                                     currentRequest: task.currentRequest.map(RequestMetric.init),
                                                     response: task.response.map(ResponseMetric.init),
                                                     error: error.map(ResponseErrorMetric.init),
                                                     requestBody: originalRequest.httpBody ?? originalRequest.httpBodyStreamData(),
                                                     responseBody: data)))
    }

    /// Tracks the progress update of a network task and generates a `TaskProgressUpdatedMetric`.
    ///
    /// - Parameters:
    ///   - task: The network task that updated its progress.
    ///   - progress: A tuple containing the completed and total bytes of the task.
    func trackTaskDidUpdateProgress(_ task: URLSessionTask, didUpdateProgress progress: (completed: Int64, total: Int64)) {
        sendEvent(.taskProgressUpdated(TaskProgressUpdatedMetric(taskId: context(for: task).taskId,
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
        sendEvent(.taskDidFinishCollecting(TaskDidFinishCollectingMetric(taskType: TaskType(task: task),
                                                                         createdAt: Date(),
                                                                         url: task.originalRequest?.url,
                                                                         taskInterval: metrics.taskInterval,
                                                                         countOfBytesReceived: task.countOfBytesReceived,
                                                                         countOfBytesSent: task.countOfBytesSent)))
    }

    /// Sends a network task event to the associated metric interceptor.
    ///
    /// - Parameter event: The network task event to be sent.
    private func sendEvent(_ event: NetworkTaskEvent) {
        metricInterceptor.sendEvent(event)
    }

    /// Retrieves the context for a given network task or creates a new one if not found.
    ///
    /// - Parameter task: The network task to retrieve the context for.
    /// - Returns: The context for the given network task.
    private func context(for task: URLSessionTask) -> TaskContext {
        let key = TaskKey(task: task)
        if let context = tasks[key] {
            return context
        }
        let context = TaskContext()
        tasks[key] = context
        return context
    }
}

/// A context object representing the state of a network task.
final class TaskContext {
    /// The unique identifier for the task context.
    let taskId = UUID()

    /// Lazy-loaded data associated with the network task.
    lazy var data = Data()
}

/// A key used to uniquely identify a network task in the `NetworkMetricsAnalyzer`.
final class TaskKey: Hashable {
    /// A weak reference to the associated network task.
    weak var task: URLSessionTask?

    /// The unique identifier for the associated network task.
    var id: ObjectIdentifier? { task.map(ObjectIdentifier.init) }

    /// Initializes a `TaskKey` with the given network task.
    ///
    /// - Parameter task: The network task to associate with the key.
    init(task: URLSessionTask?) {
        self.task = task
    }

    /// Computes the hash value for the `TaskKey`.
    ///
    /// - Parameter hasher: The hasher to use for combining the hash values.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id?.hashValue)
    }

    /// Checks if two `TaskKey` instances are equal.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `TaskKey`.
    ///   - rhs: The right-hand side `TaskKey`.
    /// - Returns: `true` if the two instances are equal, otherwise `false`.
    static func == (lhs: TaskKey, rhs: TaskKey) -> Bool {
        lhs.task != nil && lhs.id == rhs.id
    }
}
