//
//  TaskDidFinishCollectingMetric.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// A metric capturing information about a network task after it finishes collecting data.
public struct TaskDidFinishCollectingMetric: Codable, Sendable {
    /// The type of the network task.
    public var taskType: TaskType

    /// The timestamp when the metric was created.
    public var createdAt: Date

    /// The URL associated with the network task.
    public var url: URL?

    /// The time interval during which the network task occurred.
    public let taskInterval: DateInterval

    /// The count of bytes received during the network task.
    public let countOfBytesReceived: Int64

    /// The count of bytes sent during the network task.
    public let countOfBytesSent: Int64

    /// Initializes a `TaskDidFinishCollectingMetric` instance.
    ///
    /// - Parameters:
    ///   - taskType: The type of the network task.
    ///   - createdAt: The timestamp when the metric was created.
    ///   - url: The URL associated with the network task.
    ///   - taskInterval: The time interval during which the network task occurred.
    ///   - transactionMetrics: Transaction metrics associated with the network task.
    ///   - countOfBytesReceived: The count of bytes received during the network task.
    ///   - countOfBytesSent: The count of bytes sent during the network task.
    init(taskType: TaskType,
         createdAt: Date,
         url: URL?,
         taskInterval: DateInterval,
         countOfBytesReceived: Int64,
         countOfBytesSent: Int64)
    {
        self.taskType = taskType
        self.createdAt = createdAt
        self.url = url
        self.taskInterval = taskInterval
        self.countOfBytesReceived = countOfBytesReceived
        self.countOfBytesSent = countOfBytesSent
    }
}
