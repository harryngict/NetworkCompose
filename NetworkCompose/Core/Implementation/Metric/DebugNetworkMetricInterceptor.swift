//
//  DebugNetworkMetricInterceptor.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public struct DebugNetworkMetricInterceptor: NetworkMetricInterceptor {
    public init() {}

    public func sendEvent(_ event: NetworkTaskEvent) {
        var taskMetric: TaskMetric
        switch event {
        case let .taskCreated(metric):
            taskMetric = metric
        case let .taskProgressUpdated(metric):
            taskMetric = metric

        case let .taskCompleted(metric):
            taskMetric = metric

        case let .taskDidFinishCollecting(metric):
            taskMetric = metric
        }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(taskMetric)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("\n🚀🚀🚀 \(event.name):\n\(jsonString)")
            } else {
                print("\n⚠️⚠️⚠️ \(event.name): Failed to convert JSON data to string.")
            }
        } catch {
            print("\n⚠️⚠️⚠️ \(event.name):\n\(error)")
        }
    }
}
