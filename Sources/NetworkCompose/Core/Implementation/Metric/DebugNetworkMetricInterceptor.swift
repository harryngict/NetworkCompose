//
//  DebugNetworkMetricInterceptor.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public struct DebugNetworkMetricInterceptor: NetworkMetricInterceptor {
    public init() {}

    public func sendEvent(_ event: NetworkTaskEvent) {
        var taskMetric: TaskMetric
        switch event {
        case let .created(metric):
            taskMetric = metric
        case let .progressUpdated(metric):
            taskMetric = metric

        case let .completed(metric):
            taskMetric = metric

        case let .didFinishCollecting(metric):
            taskMetric = metric
        }

        do {
            print("==============METRIC_REPORT_START==============")
            print("🚀 NetworkCompose event name: \(event.name):")
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            if let metricReport = try String(data: encoder.encode(taskMetric), encoding: .utf8) {
                print("\n\(metricReport)")
            } else {
                print("🚫 NetworkCompose failed to convert json for metric name \(event.name)")
            }
            print("==============METRIC_REPORT_END==============")
            print("\n")
        } catch {
            print("🚫 NetworkCompose can not parse metric name \(event.name):  \(error.localizedDescription)")
        }
    }
}
