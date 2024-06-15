//
//  MetricsCollectorInterface.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 23/11/23.
//

import Foundation

/// @mockable
public protocol MetricsCollectorInterface: AnyObject {
  /// Informs the collector that a network task has been created.
  ///
  /// - Parameter task: The network task that was created.
  func taskCreated(_ task: URLSessionTask)

  /// Informs the collector that a network task has completed with an error.
  ///
  /// - Parameters:
  ///   - task: The network task that completed.
  ///   - error: An optional error indicating how the task completed, or `nil` if the task was successful.
  func taskDidCompleteWithError(_ task: URLSessionTask, error: Error?)

  /// Informs the collector that a network task has finished collecting metrics.
  ///
  /// - Parameters:
  ///   - task: The network task that finished collecting metrics.
  ///   - metrics: The collected URLSessionTaskMetrics.
  func taskDidFinishCollecting(_ task: URLSessionTask, metrics: URLSessionTaskMetrics)
}
