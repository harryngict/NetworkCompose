//
//  OperationQueueManagerImp.swift
//  NetworkQueue/Implementation
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

public final class OperationQueueManagerImp: OperationQueueManager {
    public let operationQueue: OperationQueue

    public init(maxConcurrentOperationCount: Int,
                qualityOfService: QualityOfService = .default)
    {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
        operationQueue.qualityOfService = qualityOfService
    }

    public func enqueue(_ operation: Operation) {
        operationQueue.addOperation(operation)
    }
}
