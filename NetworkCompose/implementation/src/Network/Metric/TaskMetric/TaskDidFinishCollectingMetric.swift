//
//  TaskDidFinishCollectingMetric.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 24/11/23.
//

import Foundation

public struct TaskDidFinishCollectingMetric: TaskMetric {
  // MARK: Lifecycle

  init(taskType: TaskType,
       createdAt: Date,
       url: URL?,
       taskInterval: DateInterval,
       countOfBytesReceived: Int64,
       countOfBytesSent: Int64,
       statusCode: Int)
  {
    self.taskType = taskType
    self.createdAt = createdAt
    self.url = url
    self.taskInterval = taskInterval
    self.countOfBytesReceived = countOfBytesReceived
    self.countOfBytesSent = countOfBytesSent
    self.statusCode = statusCode
  }

  // MARK: Public

  public var taskType: TaskType
  public var createdAt: Date
  public var url: URL?
  public let taskInterval: DateInterval
  public let countOfBytesReceived: Int64
  public let countOfBytesSent: Int64
  public let statusCode: Int
}
