//
//  NetworkReachabilityMock.swift
//  CoreMocks
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation
import Network

public class NetworkReachabilityMock: NetworkReachability {
    public init() {}
    public init(isInternetAvailable: Bool = false) {
        self.isInternetAvailable = isInternetAvailable
    }

    public private(set) var isInternetAvailableSetCallCount = 0
    public var isInternetAvailable: Bool = false { didSet { isInternetAvailableSetCallCount += 1 } }

    public private(set) var startMonitoringCallCount = 0
    public var startMonitoringHandler: ((@escaping ((_ isReachable: Bool) -> Void)) -> Void)?
    public func startMonitoring(completion: @escaping ((_ isReachable: Bool) -> Void)) {
        startMonitoringCallCount += 1
        if let startMonitoringHandler = startMonitoringHandler {
            startMonitoringHandler(completion)
        }
    }

    public private(set) var stopMonitoringCallCount = 0
    public var stopMonitoringHandler: (() -> Void)?
    public func stopMonitoring() {
        stopMonitoringCallCount += 1
        if let stopMonitoringHandler = stopMonitoringHandler {
            stopMonitoringHandler()
        }
    }
}
