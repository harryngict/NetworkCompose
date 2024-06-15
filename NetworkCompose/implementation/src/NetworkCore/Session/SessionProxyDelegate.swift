//
//  SessionProxyDelegate.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 23/11/23.
//

import Foundation

// MARK: - SessionProxyDelegate

/// `SessionProxyDelegate` is a class responsible for handling SSL pinning, metrics reporting, and logging in a network session.
open class SessionProxyDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
  // MARK: Lifecycle

  /// Initializes a `SessionProxyDelegate` with SSL pinning, metric task reporting, and logging components.
  ///
  /// - Parameters:
  ///   - sslPinningPolicy: The SSL pinning policy for secure network communication.
  ///   - reportMetricStrategy: The strategy for reporting metrics related to network tasks.
  ///   - loggerInterface: An optional logger interface for custom logging. Pass `nil` to disable logging.
  public required init(sslPinningPolicy: SSLPinningPolicy = .disabled,
                       reportMetricStrategy: ReportMetricStrategy = .disabled,
                       loggerInterface: LoggerInterface? = nil)
  {
    sslPinningProcessor = SSLPinningProcessor(
      sslPinningPolicy: sslPinningPolicy,
      loggerInterface: loggerInterface)

    if case let .enabled(metricInterceptor) = reportMetricStrategy {
      metricsCollector = MetricsCollector(metricInterceptor: metricInterceptor)
    }
  }

  // MARK: Public

  /// A closure to handle the completion of network tasks.
  public var completionHandler: ((URLResponse?, Error?) -> Void)?

  /// Updates SSL pinning policy, metric task reporting strategy, and logger interface.
  ///
  /// - Parameters:
  ///   - sslPinningPolicy: The updated SSL pinning policy.
  ///   - reportMetricStrategy: The updated strategy for reporting metrics related to network tasks.
  ///   - loggerInterface: The updated logger interface. Pass `nil` to disable logging.
  public func update(sslPinningPolicy: SSLPinningPolicy,
                     reportMetricStrategy: ReportMetricStrategy,
                     loggerInterface: LoggerInterface?)
  {
    sslPinningProcessor = SSLPinningProcessor(
      sslPinningPolicy: sslPinningPolicy,
      loggerInterface: loggerInterface)

    if case let .enabled(metricInterceptor) = reportMetricStrategy {
      metricsCollector = MetricsCollector(metricInterceptor: metricInterceptor)
    }
  }

  // MARK: Private

  /// The SSL pinning processor for secure network communication.
  private var sslPinningProcessor: SSLPinningProcessorInterface

  /// The metrics collector for reporting metrics related to network tasks.
  private var metricsCollector: MetricsCollectorInterface?
}

// MARK: SSL

public extension SessionProxyDelegate {
  /// Tells the delegate that the session task received an authentication challenge.
  ///
  /// - Parameters:
  ///   - session: The session containing the task.
  ///   - challenge: The authentication challenge.
  ///   - completionHandler: A closure to call when the challenge is handled.
  func urlSession(_: URLSession,
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
}

// MARK: URLSessionTaskDelegate

public extension SessionProxyDelegate {
  /// Tells the delegate that the session task was just created.
  ///
  /// - Parameters:
  ///   - session: The session containing the task.
  ///   - task: The new task.
  func urlSession(_: URLSession, didCreateTask task: URLSessionTask) {
    metricsCollector?.taskCreated(task)
  }

  /// Tells the delegate that the session task finished transferring data with an error.
  ///
  /// - Parameters:
  ///   - session: The session containing the task.
  ///   - task: The task whose transfer was complete.
  ///   - error: An error that indicates why the transfer failed.
  func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    metricsCollector?.taskDidCompleteWithError(task, error: error)
    completionHandler?(task.response, error)
  }

  /// Tells the delegate that the session task finished collecting metrics.
  ///
  /// - Parameters:
  ///   - session: The session containing the task.
  ///   - task: The task whose metrics have been collected.
  ///   - metrics: The collected metrics.
  func urlSession(_: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
    metricsCollector?.taskDidFinishCollecting(task, metrics: metrics)
    completionHandler?(task.response, nil)
  }
}
