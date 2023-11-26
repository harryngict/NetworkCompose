//
//  NetworkRetryPolicy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public enum NetworkRetryPolicy: Sendable {
    case none

    /// Constant retry policy with a fixed number of retry attempts and a constant delay between retries.
    ///
    /// - Parameters:
    ///   - count: The maximum number of retry attempts.
    ///   - delay: The constant delay between retry attempts. Default is 5.0 seconds.
    case constant(count: Int, delay: TimeInterval = 5.0)

    /// Exponential backoff retry policy with an increasing delay between retries.
    ///
    /// - Parameters:
    ///   - count: The maximum number of retry attempts.
    ///   - initialDelay: The initial delay before the first retry attempt. Default is 1.0 second.
    ///   - multiplier: The factor by which the delay increases after each retry. Default is 5.0.
    ///   - maxDelay: The maximum delay between retries, even after exponential growth. Default is 30.0 seconds.
    /// Formula for calculating delay: `delay = min(initialDelay * pow(multiplier, count), maxDelay)`
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