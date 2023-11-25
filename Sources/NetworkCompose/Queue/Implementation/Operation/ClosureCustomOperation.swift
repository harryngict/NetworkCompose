//
//  ClosureCustomOperation.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

final class ClosureCustomOperation: CustomOperation {
    typealias Closure = (ClosureCustomOperation) -> Void
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
        guard !isCancelled else {
            return
        }
        closure(self)
    }
}
