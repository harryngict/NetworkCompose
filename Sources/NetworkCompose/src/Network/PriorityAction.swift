//
//  PriorityAction.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 28/11/23.
//

import Foundation

public class PriorityAction: Comparable {
    /// The priority level of the action.
    public let priority: Priority

    /// The creation date of the action.
    public let createdAt: Date

    /// A closure containing the network action to be executed.
    public let actionBlock: (@escaping (Any) -> Void) -> Void

    /// Initializes a prioritized network action.
    ///
    /// - Parameters:
    ///   - priority: The priority level of the action.
    ///   - createdAt: The creation date of the action.
    ///   - actionBlock: A closure containing the network action to be executed.
    public init(priority: Priority, createdAt: Date, actionBlock: @escaping (@escaping (Any) -> Void) -> Void) {
        self.priority = priority
        self.createdAt = createdAt
        self.actionBlock = actionBlock
    }

    /// Compares two `PriorityAction` instances for sorting based on priority and creation date.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `PriorityAction` to compare.
    ///   - rhs: The right-hand side `PriorityAction` to compare.
    /// - Returns: `true` if `lhs` should run before `rhs`; otherwise, `false`.
    public static func < (lhs: PriorityAction, rhs: PriorityAction) -> Bool {
        if lhs.priority < rhs.priority {
            return true
        } else if lhs.priority == rhs.priority {
            return lhs.createdAt < rhs.createdAt
        } else {
            return false
        }
    }

    /// Checks if two `PriorityAction` instances are equal based on their priorities and creation timestamps.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `PriorityAction`.
    ///   - rhs: The right-hand side `PriorityAction`.
    /// - Returns: `true` if the instances are equal; otherwise, `false`.
    public static func == (lhs: PriorityAction, rhs: PriorityAction) -> Bool {
        return lhs.priority == rhs.priority && lhs.createdAt == rhs.createdAt
    }
}
