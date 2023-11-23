//
//  TaskProgressUpdatedMetric.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A metric capturing information about the progress update of a network task.
public struct TaskProgressUpdatedMetric: TaskMetric {
    /// The unique identifier for the network task.
    public var taskId: UUID

    /// The URL associated with the progress update, if applicable.
    public var url: URL?

    /// The number of units of work that have been completed.
    public var completedUnitCount: Int64

    /// The total number of units of work for the task.
    public var totalUnitCount: Int64

    /// Initializes a `TaskProgressUpdatedMetric` instance.
    ///
    /// - Parameters:
    ///   - taskId: The unique identifier for the network task.
    ///   - url: The URL associated with the progress update, if applicable.
    ///   - completedUnitCount: The number of units of work that have been completed.
    ///   - totalUnitCount: The total number of units of work for the task.
    public init(taskId: UUID,
                url: URL?,
                completedUnitCount: Int64,
                totalUnitCount: Int64)
    {
        self.taskId = taskId
        self.url = url
        self.completedUnitCount = completedUnitCount
        self.totalUnitCount = totalUnitCount
    }
}
