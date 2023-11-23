//
//  NetworkRetryPolicy.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A policy that defines how network requests should be retried.
public enum NetworkRetryPolicy: Sendable {
    /// No retry will be attempted.
    case none

    /// Retry the request up to the specified count with a default delay between each attempt.
    ///
    /// - Parameters:
    ///   - count: The maximum number of retry attempts.
    ///   - delay: The delay (in seconds) between retry attempts. Default is 5.0 second.
    case retry(count: Int, delay: TimeInterval = 5.0)

    /// The number of retry attempts allowed by the policy.
    var retryCount: Int {
        switch self {
        case .none:
            return 0
        case let .retry(count, _):
            return count
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
        case let .retry(_, delay):
            return currentRetry > 0 ? delay : nil
        }
    }
}
