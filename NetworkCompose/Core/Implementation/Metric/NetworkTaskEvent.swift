//
//  NetworkTaskEvent.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// An enumeration representing various events related to a network task.
public enum NetworkTaskEvent: Codable, Sendable {
    /// Indicates that a network task has been created.
    case created(_ metric: TaskCreatedMetric)

    /// Indicates that the progress of a network task has been updated.
    case progressUpdated(_ metric: TaskProgressUpdatedMetric)

    /// Indicates that a network task has been completed.
    case completed(_ metric: TaskCompletedMetric)

    /// Indicates that metrics for a network task have been collected.
    case didFinishCollecting(_ metric: TaskDidFinishCollectingMetric)

    /// The URL associated with the event, if applicable.
    var name: String {
        switch self {
        case .created: return "TaskCreated"
        case .progressUpdated: return "TaskProgressUpdated"
        case .completed: return "TaskCompleted"
        case .didFinishCollecting: return "TaskDidFinishCollecting"
        }
    }
}
