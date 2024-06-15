//
//  TaskMetricEvent.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 23/11/23.
//

import Foundation

public enum TaskMetricEvent: Codable, Sendable {
  case created(_ metric: TaskCreatedMetric)
  case completed(_ metric: TaskCompletedMetric)
  case didFinishCollecting(_ metric: TaskDidFinishCollectingMetric)

  // MARK: Public

  public var name: String {
    switch self {
    case .created: return "TaskCreated"
    case .completed: return "TaskCompleted"
    case .didFinishCollecting: return "TaskDidFinishCollecting"
    }
  }

  public var metric: TaskMetric {
    switch self {
    case let .created(metric): return metric
    case let .completed(metric): return metric
    case let .didFinishCollecting(metric): return metric
    }
  }
}
