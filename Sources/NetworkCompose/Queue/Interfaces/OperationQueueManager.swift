//
//  OperationQueueManager.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

/// A protocol for managing operation queues and enqueuing operations.
public protocol OperationQueueManager: AnyObject {
    // MARK: - Properties

    /// The operation queue managed by the manager.
    var operationQueue: OperationQueue { get }

    // MARK: - Operation Handling

    /// Enqueues the provided operation for execution.
    ///
    /// - Parameter operation: The operation to be added to the queue.
    func enqueue(_ operation: Operation)
}
