//
//  DispatchQueueType.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public protocol DispatchQueueType {
    func async(work: @escaping () -> Void)
    func asyncAfter(deadline: DispatchTime, work: @escaping () -> Void)
}

extension DispatchQueue: DispatchQueueType {
    public func async(work: @escaping () -> Void) {
        async(execute: work)
    }

    public func asyncAfter(deadline: DispatchTime, work: @escaping () -> Void) {
        asyncAfter(deadline: deadline, execute: work)
    }
}

public enum DefaultNetworkDispatchQueue: Sendable {
    public static let executeQueue: DispatchQueueType = DispatchQueue(label: "com.NetworkCompose.DispatchQueueType", qos: .userInitiated, attributes: .concurrent)
    public static let observeQueue: DispatchQueueType = DispatchQueue.main
}
