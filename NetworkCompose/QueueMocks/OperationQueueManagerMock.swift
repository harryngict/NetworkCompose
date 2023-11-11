//
//  OperationQueueManagerMock.swift
//  NetworkCompose/QueueMocks
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

public class OperationQueueManagerMock: OperationQueueManager {
    public init() {}
    public init(operationQueue: OperationQueue) {
        _operationQueue = operationQueue
    }

    public private(set) var operationQueueSetCallCount = 0
    private var _operationQueue: OperationQueue! { didSet { operationQueueSetCallCount += 1 } }
    public var operationQueue: OperationQueue {
        get { return _operationQueue }
        set { _operationQueue = newValue }
    }

    public private(set) var enqueueCallCount = 0
    public var enqueueHandler: ((Operation) -> Void)?
    public func enqueue(_ operation: Operation) {
        enqueueCallCount += 1
        if let enqueueHandler = enqueueHandler {
            enqueueHandler(operation)
        }
    }
}
