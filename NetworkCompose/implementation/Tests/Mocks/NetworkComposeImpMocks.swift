//
// Updated on 06/18/24.
// Copyright © 2024. All rights reserved.
////
/// @Generated by Mockolo
///

import Foundation
@testable import NetworkComposeImp

// MARK: - TaskMetricMock

public class TaskMetricMock: TaskMetric, @unchecked Sendable {
  public init() {}
}

// MARK: - LoggerInterfaceMock

public class LoggerInterfaceMock: LoggerInterface {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public private(set) var logCallCount = 0
  public var logHandler: ((LoggerType, String) -> Void)?

  public func log(_ type: LoggerType, _ message: String) {
    logCallCount += 1
    if let logHandler {
      logHandler(type, message)
    }
  }
}

// MARK: - SSLPinningInterfaceMock

public class SSLPinningInterfaceMock: SSLPinningInterface {
  // MARK: Lifecycle

  public init() {}
  public init(host: String = "", hashKeys: Set<String> = Set<String>()) {
    self.host = host
    self.hashKeys = hashKeys
  }

  // MARK: Public

  public private(set) var hostSetCallCount = 0
  public private(set) var hashKeysSetCallCount = 0
  public var hashKeys = Set<String>() { didSet { hashKeysSetCallCount += 1 } }

  public var host = "" { didSet { hostSetCallCount += 1 } }
}

// MARK: - MetricsCollectorInterfaceMock

public class MetricsCollectorInterfaceMock: MetricsCollectorInterface {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public private(set) var taskCreatedCallCount = 0
  public var taskCreatedHandler: ((URLSessionTask) -> Void)?
  public private(set) var taskDidCompleteWithErrorCallCount = 0
  public var taskDidCompleteWithErrorHandler: ((URLSessionTask, Error?) -> Void)?
  public private(set) var taskDidFinishCollectingCallCount = 0
  public var taskDidFinishCollectingHandler: ((URLSessionTask, URLSessionTaskMetrics) -> Void)?

  public func taskCreated(_ task: URLSessionTask) {
    taskCreatedCallCount += 1
    if let taskCreatedHandler {
      taskCreatedHandler(task)
    }
  }

  public func taskDidCompleteWithError(_ task: URLSessionTask, error: Error?) {
    taskDidCompleteWithErrorCallCount += 1
    if let taskDidCompleteWithErrorHandler {
      taskDidCompleteWithErrorHandler(task, error)
    }
  }

  public func taskDidFinishCollecting(_ task: URLSessionTask, metrics: URLSessionTaskMetrics) {
    taskDidFinishCollectingCallCount += 1
    if let taskDidFinishCollectingHandler {
      taskDidFinishCollectingHandler(task, metrics)
    }
  }
}

// MARK: - MetricInterceptorInterfaceMock

public class MetricInterceptorInterfaceMock: MetricInterceptorInterface {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public private(set) var sendEventCallCount = 0
  public var sendEventHandler: ((TaskMetricEvent) -> Void)?

  public func sendEvent(_ event: TaskMetricEvent) {
    sendEventCallCount += 1
    if let sendEventHandler {
      sendEventHandler(event)
    }
  }
}