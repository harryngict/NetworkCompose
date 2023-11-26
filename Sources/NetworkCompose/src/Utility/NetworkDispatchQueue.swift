//
//  NetworkDispatchQueue.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public protocol NetworkDispatchQueue {
    func async(work: @escaping () -> Void)
    func asyncAfter(deadline: DispatchTime, work: @escaping () -> Void)
}

extension DispatchQueue: NetworkDispatchQueue {
    public func async(work: @escaping () -> Void) {
        async(execute: work)
    }

    public func asyncAfter(deadline: DispatchTime, work: @escaping () -> Void) {
        asyncAfter(deadline: deadline, execute: work)
    }
}

public enum DefaultNetworkDispatchQueue: Sendable {
    public static let executeQueue: NetworkDispatchQueue = DispatchQueue(label: "com.NetworkCompose.NetworkDispatchQueue", qos: .userInitiated)
    public static let observeQueue: NetworkDispatchQueue = DispatchQueue.main
}
