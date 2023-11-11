//
//  CustomOperation.swift
//  NetworkQueue/Implementation
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

class CustomOperation: Operation {
    var validOperation: Bool = true

    enum State: String {
        case waiting = "isWaiting"
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
        case cancelled = "isCancelled"
    }

    var state: State = .waiting {
        willSet {
            willChangeValue(forKey: State.ready.rawValue)
            willChangeValue(forKey: State.executing.rawValue)
            willChangeValue(forKey: State.finished.rawValue)
            willChangeValue(forKey: State.cancelled.rawValue)
        }
        didSet {
            switch self.state {
            case .waiting: assert(oldValue == .waiting, "Invalid change from \(oldValue) to \(self.state)")
            case .ready: assert(oldValue == .waiting, "Invalid change from \(oldValue) to \(self.state)")
            case .executing: assert(oldValue == .ready || oldValue == .waiting, "Invalid change from \(oldValue) to \(self.state)")
            case .finished: assert(oldValue != .cancelled, "Invalid change from \(oldValue) to \(self.state)")
            case .cancelled: break
            }

            didChangeValue(forKey: State.cancelled.rawValue)
            didChangeValue(forKey: State.finished.rawValue)
            didChangeValue(forKey: State.executing.rawValue)
            didChangeValue(forKey: State.ready.rawValue)
        }
    }

    override var isReady: Bool {
        if self.state == .waiting {
            return super.isReady
        } else {
            return self.state == .ready
        }
    }

    override var isExecuting: Bool {
        if self.state == .waiting {
            return super.isExecuting
        } else {
            return self.state == .executing
        }
    }

    override var isFinished: Bool {
        if self.state == .waiting {
            return super.isFinished
        } else {
            return self.state == .finished
        }
    }

    override var isCancelled: Bool {
        if self.state == .waiting {
            return super.isCancelled
        } else {
            return self.state == .cancelled
        }
    }

    override var isAsynchronous: Bool {
        return true
    }

    override func start() {
        guard validOperation else {
            state = .finished
            return
        }
        super.start()
    }
}
