//
//  NetworkRetryPolicy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public enum NetworkRetryPolicy: Sendable {
    case none
    case constant(count: Int, delay: TimeInterval = 5.0)
    case exponentialRetry(count: Int,
                          initialDelay: TimeInterval = 1.0,
                          multiplier: Double = 5.0,
                          maxDelay: TimeInterval = 30.0)

    var retryCount: Int {
        switch self {
        case .none: return 0
        case let .constant(count, _): return count
        case let .exponentialRetry(count, _, _, _): return count
        }
    }

    func shouldRetry(currentRetry: Int) -> Bool {
        debugPrint("🔄 NetworkCompose retry count: \(currentRetry)")
        return currentRetry <= retryCount
    }

    func retryDelay(currentRetry: Int) -> TimeInterval? {
        switch self {
        case .none:
            return nil
        case let .exponentialRetry(_, initialDelay, multiplier, maxDelay):
            let delay = initialDelay * pow(multiplier, Double(currentRetry - 1))
            return currentRetry > 0 ? min(maxDelay, delay) : nil

        case let .constant(_, delay):
            return delay
        }
    }
}
