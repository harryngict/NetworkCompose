//
//  NetworkMetricsCollectorImp.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public final class NetworkMetricsCollectorImp: NetworkMetricsCollector {
    public init() {}

    public func taskCreated(_ task: NetworkTask) {
        debugPrint("taskCreated: \(task)")
    }

    public func taskDidCompleteWithError(_ task: NetworkTask, error _: Error?) {
        debugPrint("taskDidCompleteWithError: \(task)")
    }

    public func taskDidFinishCollecting(_ task: NetworkTask, metrics _: URLSessionTaskMetrics) {
        debugPrint("taskDidFinishCollecting: \(task)")
    }

    public func taskDidUpdateProgres(_ task: NetworkTask, progress _: (completed: Int64, total: Int64)) {
        debugPrint("taskDidUpdateProgres: \(task)")
    }

    public func taskDidReceive(_ task: NetworkTask, data _: Data) {
        debugPrint("taskDidReceive: \(task)")
    }

    public func taskDidFinishDownload(_ task: NetworkTask, location _: URL) {
        debugPrint("taskDidFinishDownload: \(task)")
    }

    public func taskDidUpdateProgress(_ task: NetworkTask, progress _: (completed: Int64, total: Int64)) {
        debugPrint("taskDidUpdateProgress: \(task)")
    }
}
