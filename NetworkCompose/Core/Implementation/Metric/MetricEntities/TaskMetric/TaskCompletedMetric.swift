//
//  TaskCompletedMetric.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A metric capturing information about the completion of a network task.
public struct TaskCompletedMetric: TaskMetric {
    /// The type of network task.
    public var taskType: TaskType

    /// The timestamp when the network task was created.
    public var createdAt: Date

    /// The original request metrics associated with the network task.
    public var originalRequest: RequestMetric

    /// The current request metrics associated with the network task, if applicable.
    public var currentRequest: RequestMetric?

    /// The response metrics associated with the network task, if available.
    public var response: ResponseMetric?

    /// The error metrics associated with the network task, if an error occurred.
    public var error: ResponseErrorMetric?

    /// The data representing the request body, if applicable.
    public var requestBody: Data?

    /// The data representing the response body, if applicable.
    public var responseBody: Data?

    /// Initializes a `TaskCompletedMetric` instance.
    ///
    /// - Parameters:
    ///   - taskType: The type of network task.
    ///   - createdAt: The timestamp when the network task was created.
    ///   - originalRequest: The original request metrics associated with the network task.
    ///   - currentRequest: The current request metrics associated with the network task, if applicable.
    ///   - response: The response metrics associated with the network task, if available.
    ///   - error: The error metrics associated with the network task, if an error occurred.
    ///   - requestBody: The data representing the request body, if applicable.
    ///   - responseBody: The data representing the response body, if applicable.
    public init(taskType: TaskType,
                createdAt: Date,
                originalRequest: RequestMetric,
                currentRequest: RequestMetric?,
                response: ResponseMetric?,
                error: ResponseErrorMetric?,
                requestBody: Data?,
                responseBody: Data?)
    {
        self.taskType = taskType
        self.createdAt = createdAt
        self.originalRequest = originalRequest
        self.currentRequest = currentRequest
        self.response = response
        self.error = error
        self.requestBody = requestBody
        self.responseBody = responseBody
    }
}
