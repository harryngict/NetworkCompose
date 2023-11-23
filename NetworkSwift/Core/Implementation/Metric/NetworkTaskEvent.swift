//
//  NetworkTaskEvent.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// An enumeration representing various events related to a network task.
public enum NetworkTaskEvent: Codable, Sendable {
    /// Indicates that a network task has been created.
    case taskCreated(_ metric: TaskCreatedMetric)

    /// Indicates that the progress of a network task has been updated.
    case taskProgressUpdated(_ metric: TaskProgressUpdatedMetric)

    /// Indicates that a network task has been completed.
    case taskCompleted(_ metric: TaskCompletedMetric)

    /// Indicates that metrics for a network task have been collected.
    case taskDidFinishCollecting(_ metric: TaskDidFinishCollectingMetric)

    /// The URL associated with the event, if applicable.
    var url: URL? {
        switch self {
        case let .taskCreated(metric): return metric.originalRequest.url
        case let .taskProgressUpdated(metric): return metric.url
        case let .taskCompleted(metric): return metric.originalRequest.url
        case let .taskDidFinishCollecting(metric): return metric.url
        }
    }
}
