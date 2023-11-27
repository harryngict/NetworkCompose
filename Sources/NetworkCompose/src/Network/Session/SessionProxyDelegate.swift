//
//  SessionProxyDelegate.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

final class SessionProxyDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    private var metricsCollector: MetricsCollectorInterface?
    private let sslPinningProcessor: SSLPinningProcessorInterface

    /// Initializes a `SessionProxyDelegate` with SSL pinning, metric task reporting, and logging components.
    ///
    /// Use this initializer to create a `SessionProxyDelegate` with SSL pinning and optional metric task reporting and logging.
    /// The SSL pinning policy is specified by `sslPinningPolicy`. Metric task reporting is controlled by `metricTaskReportStrategy`,
    /// and the optional `loggerInterface` provides a custom logging implementation.
    ///
    /// - Parameters:
    ///   - sslPinningPolicy: The SSL pinning policy for secure network communication.
    ///   - metricTaskReportStrategy: The strategy for reporting metrics related to network tasks.
    ///   - loggerInterface: An optional logger interface for custom logging. Pass `nil` to disable logging.
    init(sslPinningPolicy: SSLPinningPolicy,
         metricTaskReportStrategy: MetricTaskReportStrategy,
         loggerInterface: LoggerInterface?)
    {
        sslPinningProcessor = SSLPinningProcessor(sslPinningPolicy: sslPinningPolicy,
                                                  loggerInterface: loggerInterface)

        if case let .enabled(metricInterceptor) = metricTaskReportStrategy {
            metricsCollector = MetricsCollector(metricInterceptor: metricInterceptor)
        }
    }

    // MARK: URLSessionTaskDelegate

    /// Tells the delegate that the session task received an authentication challenge.
    public func urlSession(_: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        guard case .trust = sslPinningProcessor.sslPinningPolicy else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        let decision = sslPinningProcessor.validateAuthentication(challenge.protectionSpace)
        completionHandler(decision.authChallengeDisposition, decision.urlCredential)
    }

    /// Tells the delegate that the session task was just created.
    public func urlSession(_: URLSession, didCreateTask task: URLSessionTask) {
        metricsCollector?.taskCreated(task)
    }

    /// Tells the delegate that the session task finished transferring data with an error.
    public func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        metricsCollector?.taskDidCompleteWithError(task, error: error)
    }

    /// Tells the delegate that the session task sent some body bytes.
    public func urlSession(_: URLSession,
                           task: URLSessionTask,
                           didSendBodyData _: Int64,
                           totalBytesSent: Int64,
                           totalBytesExpectedToSend: Int64)
    {
        if task is URLSessionUploadTask {
            metricsCollector?.taskDidUpdateProgress(task,
                                                    progress: (completed: totalBytesSent, total: totalBytesExpectedToSend))
        }
    }

    /// Tells the delegate that the download task has written data to the disk.
    public func urlSession(_: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData _: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64)
    {
        metricsCollector?.taskDidUpdateProgress(downloadTask,
                                                progress: (completed: totalBytesWritten, total: totalBytesExpectedToWrite))
    }

    /// Tells the delegate that the session task finished collecting metrics.
    public func urlSession(_: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        metricsCollector?.taskDidFinishCollecting(task, metrics: metrics)
    }
}
