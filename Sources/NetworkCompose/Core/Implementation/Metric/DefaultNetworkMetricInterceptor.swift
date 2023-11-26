//
//  DefaultNetworkMetricInterceptor.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public typealias MetricReportHandler = (_ event: NetworkTaskEvent) -> Void

public struct DefaultNetworkMetricInterceptor: NetworkMetricInterceptor {
    var reportHandler: MetricReportHandler

    public init(_ reportHandler: @escaping MetricReportHandler) {
        self.reportHandler = reportHandler
    }

    public func sendEvent(_ event: NetworkTaskEvent) {
        /// Throw report to app incase use default
        reportHandler(event)

        /// Noted: Here is local print
        let taskMetric: TaskMetric = event.taskMetric

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
