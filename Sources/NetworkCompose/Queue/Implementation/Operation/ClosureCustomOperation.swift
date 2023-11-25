//
//  ClosureCustomOperation.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

/// A subclass of `CustomOperation` that executes a closure when its `main()` method is called.
final class ClosureCustomOperation: CustomOperation {
    /// The type definition for the closure executed by the operation.
    typealias Closure = (ClosureCustomOperation) -> Void

    /// The closure to be executed by the operation.
    private let closure: Closure

    /// Initializes the operation with the given closure.
    ///
    /// - Parameter closure: The closure to be executed when the operation is started.
    init(closure: @escaping Closure) {
        self.closure = closure
    }

    /// The main execution point for the operation.
    ///
    /// This method is called when the operation is ready to execute.
    override func main() {
        // Check if the operation is not cancelled before executing the closure
        guard !isCancelled else {
            return
        }
        // Execute the closure
        closure(self)
    }
}
