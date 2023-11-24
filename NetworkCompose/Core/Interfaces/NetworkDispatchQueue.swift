//
//  NetworkDispatchQueue.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// Represents a network dispatch queue.
public protocol NetworkDispatchQueue {
    /// Asynchronously executes the specified work on the queue.
    func async(work: @escaping () -> Void)

    /// Asynchronously executes the specified work after the specified time on the queue.
    func asyncAfter(deadline: DispatchTime, work: @escaping () -> Void)
}

/// An extension on DispatchQueue to conform to the NetworkDispatchQueue protocol.
extension DispatchQueue: NetworkDispatchQueue {
    /// Asynchronously executes the specified work on the queue.
    public func async(work: @escaping () -> Void) {
        async(execute: work)
    }

    /// Asynchronously executes the specified work after the specified time on the queue.
    public func asyncAfter(deadline: DispatchTime, work: @escaping () -> Void) {
        asyncAfter(deadline: deadline, execute: work)
    }
}

/// A namespace for default network dispatch queues.
public enum DefaultNetworkDispatchQueue: Sendable {
    /// The default execution queue for network operations.
    public static let executeQueue: NetworkDispatchQueue = DispatchQueue(label: "com.NetworkCompose.NetworkDispatchQueue", qos: .userInitiated)

    /// The default observation queue for network events.
    public static let observeQueue: NetworkDispatchQueue = DispatchQueue.main
}
