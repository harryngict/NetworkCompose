//
//  OperationQueueManagerImp.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

public final class OperationQueueManagerImp: OperationQueueManager {
    public let operationQueue: OperationQueue

    /// Creates an instance of `OperationQueueManagerImp`.
    ///
    /// - Parameters:
    ///   - maxConcurrentOperationCount: The maximum number of operations that can be executed concurrently.
    ///   - qualityOfService: The quality of service for the operation queue.
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

public enum DefaultOperationQueueManager {
    public static let serialOperationQueue: OperationQueueManager = OperationQueueManagerImp(maxConcurrentOperationCount: 1)
}
