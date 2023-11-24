//
//  TaskCreatedMetric.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A metric capturing information about the creation of a network task.
public struct TaskCreatedMetric: TaskMetric {
    /// The type of the network task.
    public var taskType: TaskType

    /// The timestamp when the metric was created.
    public var createdAt: Date

    /// The original request associated with the network task.
    public var originalRequest: RequestMetric

    /// The current request associated with the network task, if applicable.
    public var currentRequest: RequestMetric?

    /// Initializes a `TaskCreatedMetric` instance.
    ///
    /// - Parameters:
    ///   - taskType: The type of the network task.
    ///   - createdAt: The timestamp when the metric was created.
    ///   - originalRequest: The original request associated with the network task.
    ///   - currentRequest: The current request associated with the network task, if applicable.
    public init(taskType: TaskType,
                createdAt: Date,
                originalRequest: RequestMetric,
                currentRequest: RequestMetric?)
    {
        self.taskType = taskType
        self.createdAt = createdAt
        self.originalRequest = originalRequest
        self.currentRequest = currentRequest
    }
}
