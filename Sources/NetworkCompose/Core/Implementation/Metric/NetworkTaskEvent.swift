//
//  NetworkTaskEvent.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public enum NetworkTaskEvent: Codable, Sendable {
    case created(_ metric: TaskCreatedMetric)
    case progressUpdated(_ metric: TaskProgressUpdatedMetric)
    case completed(_ metric: TaskCompletedMetric)
    case didFinishCollecting(_ metric: TaskDidFinishCollectingMetric)

    var name: String {
        switch self {
        case .created: return "TaskCreated"
        case .progressUpdated: return "TaskProgressUpdated"
        case .completed: return "TaskCompleted"
        case .didFinishCollecting: return "TaskDidFinishCollecting"
        }
    }
}
