//
//  TaskCreatedMetric.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 23/11/23.
//

import Foundation

public struct TaskCreatedMetric: TaskMetric {
  // MARK: Lifecycle

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

  // MARK: Public

  public var taskType: TaskType
  public var createdAt: Date
  public var originalRequest: RequestMetric
  public var currentRequest: RequestMetric?
}
