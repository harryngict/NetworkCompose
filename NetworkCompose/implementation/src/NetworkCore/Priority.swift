//
//  Priority.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 28/11/23.
//

import Foundation

public enum Priority: Comparable {
  /// The high priority level.
  case high

  /// The medium priority level.
  case medium

  /// The low priority level.
  case low

  // MARK: Public

  /// Compares two `Priority` instances based on their ordering.
  ///
  /// - Returns: `true` if `lhs` is less than `rhs` based on ordering; otherwise, `false`.
  public static func < (lhs: Priority, rhs: Priority) -> Bool {
    switch (lhs, rhs) {
    case (.high, .low),
         (.high, .medium),
         (.medium, .low):
      return true
    default:
      return false
    }
  }
}
