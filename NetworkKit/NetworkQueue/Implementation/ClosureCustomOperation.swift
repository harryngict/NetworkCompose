//
//  ClosureCustomOperation.swift
//  NetworkQueue/Implementation
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

final class ClosureCustomOperation: CustomOperation {
    typealias Closure = (ClosureCustomOperation) -> Void

    private let closure: Closure

    init(closure: @escaping Closure) {
        self.closure = closure
    }

    override func main() {
        guard !isCancelled else {
            return
        }
        closure(self)
    }
}
