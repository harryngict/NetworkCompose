//
//  CustomOperation.swift
//  NetworkSwift/Queue
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

/// A custom subclass of `Operation` providing additional control and state management.
class CustomOperation: Operation {
    /// Indicates whether the operation is considered valid or not.
    var validOperation: Bool = true

    /// Possible states for the operation.
    enum State: String {
        case waiting = "isWaiting"
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
        case cancelled = "isCancelled"
    }

    /// The current state of the operation.
    var state: State = .waiting {
        willSet {
            willChangeValue(forKey: State.ready.rawValue)
            willChangeValue(forKey: State.executing.rawValue)
            willChangeValue(forKey: State.finished.rawValue)
            willChangeValue(forKey: State.cancelled.rawValue)
        }
        didSet {
            // Ensure valid transitions between states
            switch self.state {
            case .waiting:
                assert(oldValue == .waiting, "Invalid change from \(oldValue) to \(self.state)")
            case .ready:
                assert(oldValue == .waiting, "Invalid change from \(oldValue) to \(self.state)")
            case .executing:
                assert(oldValue == .ready || oldValue == .waiting, "Invalid change from \(oldValue) to \(self.state)")
            case .finished:
                assert(oldValue != .cancelled, "Invalid change from \(oldValue) to \(self.state)")
            case .cancelled:
                break
            }

            didChangeValue(forKey: State.cancelled.rawValue)
            didChangeValue(forKey: State.finished.rawValue)
            didChangeValue(forKey: State.executing.rawValue)
            didChangeValue(forKey: State.ready.rawValue)
        }
    }

    /// Overrides the default `isReady` property based on the custom state.
    override var isReady: Bool {
        if self.state == .waiting {
            return super.isReady
        } else {
            return self.state == .ready
        }
    }

    /// Overrides the default `isExecuting` property based on the custom state.
    override var isExecuting: Bool {
        if self.state == .waiting {
            return super.isExecuting
        } else {
            return self.state == .executing
        }
    }

    /// Overrides the default `isFinished` property based on the custom state.
    override var isFinished: Bool {
        if self.state == .waiting {
            return super.isFinished
        } else {
            return self.state == .finished
        }
    }

    /// Overrides the default `isCancelled` property based on the custom state.
    override var isCancelled: Bool {
        if self.state == .waiting {
            return super.isCancelled
        } else {
            return self.state == .cancelled
        }
    }

    /// Indicates whether the operation is asynchronous.
    override var isAsynchronous: Bool {
        return true
    }

    /// Starts the execution of the operation, considering its validity.
    override func start() {
        guard validOperation else {
            state = .finished
            return
        }
        super.start()
    }
}
