//
//  LocalNetworkMetricInterceptor.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public struct LocalNetworkMetricInterceptor: NetworkMetricInterceptor {
    public init() {}

    public func sendEvent(_ event: NetworkTaskEvent) {
        switch event {
        case let .taskCreated(metric):
            debugPrint("LocalNetworkMetric: taskCreated: \(metric)")

        case let .taskProgressUpdated(metric):
            debugPrint("LocalNetworkMetric: taskProgressUpdated: \(metric)")

        case let .taskCompleted(metric):
            debugPrint("LocalNetworkMetric: taskCompleted: \(metric)")

        case let .taskDidFinishCollecting(metric):
            debugPrint("LocalNetworkMetric: taskDidFinishCollecting: \(metric)")
        }
    }
}
