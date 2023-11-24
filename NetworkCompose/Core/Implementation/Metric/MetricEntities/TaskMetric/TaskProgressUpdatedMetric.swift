//
//  TaskProgressUpdatedMetric.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A metric capturing information about the progress update of a network task.
public struct TaskProgressUpdatedMetric: TaskMetric {
    /// The type of network task.
    public var taskType: TaskType

    /// The timestamp when the network task was created.
    public var createdAt: Date

    /// The URL associated with the progress update, if applicable.
    public var url: URL?

    /// The number of units of work that have been completed.
    public var completedUnitCount: Int64

    /// The total number of units of work for the task.
    public var totalUnitCount: Int64

    /// Initializes a `TaskProgressUpdatedMetric` instance.
    ///
    /// - Parameters:
    ///   - taskType: The type of network task.
    ///   - createdAt: The timestamp when the network task was created.
    ///   - url: The URL associated with the progress update, if applicable.
    ///   - completedUnitCount: The number of units of work that have been completed.
    ///   - totalUnitCount: The total number of units of work for the task.
    public init(taskType: TaskType,
                createdAt: Date,
                url: URL?,
                completedUnitCount: Int64,
                totalUnitCount: Int64)
    {
        self.taskType = taskType
        self.createdAt = createdAt
        self.url = url
        self.completedUnitCount = completedUnitCount
        self.totalUnitCount = totalUnitCount
    }
}
