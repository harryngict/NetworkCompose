//
//  NetworkSessionProxyDelegate.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// `NetworkSessionProxyDelegate` serves as a delegate for `URLSession` tasks, handling various events
/// and collecting network metrics.
final class NetworkSessionProxyDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    /// The metrics collector for collecting network metrics.
    private var metricsCollector: NetworkMetricsCollector?

    /// The SSL pinning processor for handling SSL challenges.
    private var sslPinningProcessor: SSLPinningProcessor

    /// Initializes the `NetworkSessionProxyDelegate` with optional metrics collector and security trust.
    ///
    /// - Parameters:
    ///   - sslPinningPolicy: An optional `NetworkSSLPinningPolicy` for SSL pinning.
    ///   - metricInterceptor: An optional `NetworkMetricInterceptor` for collecting network metrics.
    /// - Returns: A new instance of `NetworkSessionProxyDelegate`.
    init(sslPinningPolicy: NetworkSSLPinningPolicy,
         metricInterceptor: NetworkMetricInterceptor?)
    {
        let securityTrust = NetworkSecurityTrustImp(sslPinnings: sslPinningPolicy.sslPinnings)
        sslPinningProcessor = SSLPinningProcessorImp(sslPinningPolicy: sslPinningPolicy,
                                                     securityTrust: securityTrust)

        if let metricInterceptor = metricInterceptor {
            metricsCollector = NetworkMetricsCollectorImp(metricInterceptor: metricInterceptor)
        }
    }

    // MARK: URLSessionTaskDelegate

    /// Tells the delegate that the session task received an authentication challenge.
    ///
    /// - Parameters:
    ///   - session: The session containing the task.
    ///   - challenge: The authentication challenge.
    ///   - completionHandler: A closure to call with the authentication decision.
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
    ///
    /// - Parameters:
    ///   - session: The session containing the task.
    ///   - task: The task that was just created.
    public func urlSession(_: URLSession, didCreateTask task: URLSessionTask) {
        metricsCollector?.taskCreated(task)
    }

    /// Tells the delegate that the session task finished transferring data with an error.
    ///
    /// - Parameters:
    ///   - session: The session containing the task.
    ///   - task: The task that finished transferring data.
    ///   - error: An error that occurred during the transfer, or nil if it was successful.
    public func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        metricsCollector?.taskDidCompleteWithError(task, error: error)
    }

    /// Tells the delegate that the session task sent some body bytes.
    ///
    /// - Parameters:
    ///   - session: The session containing the task.
    ///   - task: The task that sent body bytes.
    ///   - totalBytesSent: The total number of bytes sent so far.
    ///   - totalBytesExpectedToSend: The total number of bytes expected to be sent.
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
    ///
    /// - Parameters:
    ///   - session: The session containing the task.
    ///   - downloadTask: The download task that wrote data.
    ///   - totalBytesWritten: The total number of bytes written to the disk.
    ///   - totalBytesExpectedToWrite: The total number of bytes expected to be written.
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
    ///
    /// - Parameters:
    ///   - session: The session containing the task.
    ///   - task: The task that finished collecting metrics.
    ///   - metrics: The collected metrics.
    public func urlSession(_: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        metricsCollector?.taskDidFinishCollecting(task, metrics: metrics)
    }
}
