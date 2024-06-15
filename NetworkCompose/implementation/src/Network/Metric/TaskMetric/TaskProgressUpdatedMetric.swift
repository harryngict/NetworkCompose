//
//  TaskProgressUpdatedMetric.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 23/11/23.
//

import Foundation

public struct TaskProgressUpdatedMetric: TaskMetric {
  // MARK: Lifecycle

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

  // MARK: Public

  public var taskType: TaskType
  public var createdAt: Date
  public var url: URL?
  public var completedUnitCount: Int64
  public var totalUnitCount: Int64
}
