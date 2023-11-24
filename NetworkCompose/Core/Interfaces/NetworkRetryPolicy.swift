//
//  NetworkRetryPolicy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A policy that defines how network requests should be retried.
public enum NetworkRetryPolicy: Sendable {
    /// No retry will be attempted.
    case none

    /// Retry the request up to the specified count with a constant delay between each attempt.
    ///
    /// - Parameters:
    ///   - count: The maximum number of retry attempts.
    ///   - time: The constant delay (in seconds) between retry attempts. Default is 5.0.
    case constant(count: Int, delay: TimeInterval = 5.0)

    /// Retry the request up to the specified count with an exponential delay between each attempt.
    ///
    /// - Parameters:
    ///   - count: The maximum number of retry attempts.
    ///   - initialDelay: The initial delay (in seconds) before the first retry attempt. Default is 1.0 second.
    ///   - multiplier: The factor by which the delay increases with each retry attempt. Default is 5.0.
    ///   - maxDelay: The maximum delay (in seconds) allowed between retries. Default is 30.0 seconds.
    case exponentialRetry(count: Int,
                          initialDelay: TimeInterval = 1.0,
                          multiplier: Double = 5.0,
                          maxDelay: TimeInterval = 30.0)

    /// The number of retry attempts allowed by the policy.
    var retryCount: Int {
        switch self {
        case .none: return 0
        case let .constant(count, _): return count
        case let .exponentialRetry(count, _, _, _): return count
        }
    }

    /// Determines whether a retry should be attempted based on the current retry count.
    ///
    /// - Parameter currentRetry: The current retry attempt.
    /// - Returns: `true` if a retry should be attempted; otherwise, `false`.
    func shouldRetry(currentRetry: Int) -> Bool {
        return currentRetry <= retryCount
    }

    /// Returns the delay for the current retry attempt.
    ///
    /// - Parameter currentRetry: The current retry attempt.
    /// - Returns: The delay (in seconds) before the next retry attempt. Returns `nil` if no delay is required.
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
