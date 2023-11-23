//
//  NetworkSessionProxyDelegate.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// NetworkSessionProxyDelegate` serves as a delegate for `URLSession` tasks, handling various events and collecting network metrics.
final class NetworkSessionProxyDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    /// The metrics collector for collecting network metrics.
    private var metricsCollector: NetworkMetricsCollector?

    /// The SSL pinning processor for handling SSL challenges.
    private var sslPinningProcessor: SSLPinningProcessor?

    /// Initializes the `NetworkSessionProxyDelegate` with optional metrics collector and security trust.
    ///
    /// - Parameters:
    ///   - metricLogger: An optional `NetworkMetricLogger` for collecting network metrics.
    ///   - securityTrust: An optional `NetworkSecurityTrust` for SSL pinning.
    /// - Returns: A new instance of `NetworkSessionProxyDelegate`.
    init(metricInterceptor: NetworkMetricInterceptor?,
         securityTrust: NetworkSecurityTrust?)
    {
        if let metricInterceptor = metricInterceptor {
            metricsCollector = NetworkMetricsCollectorImp(metricInterceptor: metricInterceptor)
        }
        if let securityTrust = securityTrust {
            sslPinningProcessor = SSLPinningProcessorImp(securityTrust: securityTrust)
        }
    }

    // MARK: URLSessionTaskDelegate

    public func urlSession(_: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        guard let sslPinningProcessor else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        let decision = sslPinningProcessor.validateAuthentication(challenge.protectionSpace)
        completionHandler(decision.authChallengeDisposition, decision.urlCredential)
    }

    public func urlSession(_: URLSession, didCreateTask task: URLSessionTask) {
        metricsCollector?.taskCreated(task)
    }

    public func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        metricsCollector?.taskDidCompleteWithError(task, error: error)
    }

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

    public func urlSession(_: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData _: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64)
    {
        metricsCollector?.taskDidUpdateProgress(downloadTask,
                                                progress: (completed: totalBytesWritten, total: totalBytesExpectedToWrite))
    }

    public func urlSession(_: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        metricsCollector?.taskDidFinishCollecting(task, metrics: metrics)
    }
}
