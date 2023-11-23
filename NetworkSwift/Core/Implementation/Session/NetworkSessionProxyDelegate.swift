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
    private let metricsCollector: NetworkMetricsCollector?

    /// The SSL pinning processor for handling SSL challenges.
    private var sslPinningProcessor: SSLPinningProcessor?

    /// Initializes the `NetworkSessionProxyDelegate` with optional metrics collector and security trust.
    ///
    /// - Parameters:
    ///   - metricsCollector: An optional `NetworkMetricsCollector` for collecting network metrics.
    ///   - securityTrust: An optional `NetworkSecurityTrust` for SSL pinning.
    /// - Returns: A new instance of `NetworkSessionProxyDelegate`.
    public init(metricsCollector: NetworkMetricsCollector? = nil,
                securityTrust: NetworkSecurityTrust? = nil)
    {
        self.metricsCollector = metricsCollector
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

    public func urlSession(_: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        metricsCollector?.taskDidFinishCollecting(task, metrics: metrics)
    }

    public func urlSession(_: URLSession,
                           task: URLSessionTask,
                           didSendBodyData _: Int64,
                           totalBytesSent: Int64,
                           totalBytesExpectedToSend: Int64)
    {
        if task is URLSessionUploadTask {
            metricsCollector?.taskDidUpdateProgres(task, progress: (completed: totalBytesSent, total: totalBytesExpectedToSend))
        }
    }

    // MARK: URLSessionDataDelegate

    public func urlSession(_: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        metricsCollector?.taskDidReceive(dataTask, data: data)
    }

    // MARK: URLSessionDownloadDelegate

    public func urlSession(_: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL)
    {
        metricsCollector?.taskDidFinishDownload(downloadTask, location: location)
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
}
