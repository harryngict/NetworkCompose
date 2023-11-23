//
//  URLSession+Metric.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A protocol for collecting network metrics during the execution of network tasks.
public protocol NetworkMetricsCollector: AnyObject {
    /// Informs the collector that a network task has been created.
    ///
    /// This method is called when a network task is created and provides an opportunity for the collector to capture relevant information.
    ///
    /// - Parameter task: The network task that was created.
    func taskCreated(_ task: NetworkTask)

    /// Informs the collector that a network task has completed with an error.
    ///
    /// This method is called when a network task has finished, whether successfully or with an error.
    ///
    /// - Parameters:
    ///   - task: The network task that completed.
    ///   - error: An optional error indicating how the task completed, or `nil` if the task was successful.
    func taskDidCompleteWithError(_ task: NetworkTask, error: Error?)

    /// Informs the collector that a network task has finished collecting metrics.
    ///
    /// This method is called when a network task has finished collecting metrics, providing the collected metrics for analysis.
    ///
    /// - Parameters:
    ///   - task: The network task that finished collecting metrics.
    ///   - metrics: The collected metrics for the network task.
    func taskDidFinishCollecting(_ task: NetworkTask, metrics: URLSessionTaskMetrics)

    /// Informs the collector that a network task has updated its progress.
    ///
    /// This method is called when a network task has updated its progress, providing information about the completed and total bytes.
    ///
    /// - Parameters:
    ///   - task: The network task that updated its progress.
    ///   - progress: A tuple containing the completed and total bytes of the task.
    func taskDidUpdateProgress(_ task: NetworkTask, progress: (completed: Int64, total: Int64))

    /// Informs the collector that a network task has received data.
    ///
    /// This method is called when a network task has received data, providing the received data for analysis.
    ///
    /// - Parameters:
    ///   - task: The network task that received data.
    ///   - data: The data received by the task.
    func taskDidReceive(_ task: NetworkTask, data: Data)

    /// Informs the collector that a network task has finished downloading.
    ///
    /// This method is called when a network download task has finished downloading, providing the location of the downloaded file.
    ///
    /// - Parameters:
    ///   - task: The network task that finished downloading.
    ///   - location: The file URL indicating the location of the downloaded file.
    func taskDidFinishDownload(_ task: NetworkTask, location: URL)
}
