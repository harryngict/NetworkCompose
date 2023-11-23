//
//  NetworkRetryPolicy.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

// TODO: Enhancement Retry policy - Smarter retry https://github.com/harryngict/NetworkSwift/issues/8
import Foundation

/// Enumeration representing the retry policy for network requests.
///
/// - `none`: No retry will be attempted.
/// - `retry(count)`: Retry the request up to the specified count.
public enum NetworkRetryPolicy: Sendable {
    /// No retry will be attempted.
    case none

    /// Retry the request up to the specified count.
    /// - Parameter count: The maximum number of retry attempts.
    case retry(count: Int)

    /// The number of retry attempts allowed by the policy.
    var retryCount: Int {
        switch self {
        case .none:
            return 0
        case let .retry(count):
            return count
        }
    }

    /// Determines whether a retry should be attempted based on the current retry count.
    /// - Parameter currentRetry: The current retry attempt.
    /// - Returns: `true` if a retry should be attempted; otherwise, `false`.
    func shouldRetry(currentRetry: Int) -> Bool {
        return currentRetry <= retryCount
    }
}
