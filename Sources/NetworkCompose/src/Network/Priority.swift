//
//  Priority.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 28/11/23.
//

import Foundation

public enum Priority: Comparable {
    /// The high priority level.
    case high

    /// The medium priority level.
    case medium

    /// The low priority level.
    case low

    /// Compares two `Priority` instances based on their ordering.
    ///
    /// - Returns: `true` if `lhs` is less than `rhs` based on ordering; otherwise, `false`.
    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        switch (lhs, rhs) {
        case (.high, .medium), (.high, .low), (.medium, .low):
            return true
        default:
            return false
        }
    }
}
