//
//  OperationQueueManagerImp.swift
//  NetworkSwift/Queue
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

/// An implementation of the `OperationQueueManager` protocol using `OperationQueue`.
public final class OperationQueueManagerImp: OperationQueueManager {
    /// The operation queue managed by this manager.
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

    /// Enqueues an operation for execution in the managed operation queue.
    ///
    /// - Parameter operation: The operation to be added to the queue.
    public func enqueue(_ operation: Operation) {
        operationQueue.addOperation(operation)
    }
}
