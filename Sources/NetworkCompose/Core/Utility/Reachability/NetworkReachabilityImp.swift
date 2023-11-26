//
//  NetworkReachabilityImp.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation
import Network

public final class NetworkReachabilityImp: NetworkReachability {
    public static let shared = NetworkReachabilityImp()

    private let monitor = NWPathMonitor()

    public var isInternetAvailable: Bool

    private init() {
        isInternetAvailable = true
    }

    public func startMonitoring(completion: @escaping ((Bool) -> Void)) {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let this = self else { return }
            this.isInternetAvailable = path.status == .satisfied
            completion(this.isInternetAvailable)
        }
        let queue = DispatchQueue(label: "com.NetworkCompose.NetworkReachabilityImp")
        monitor.start(queue: queue)
    }

    public func stopMonitoring() {
        monitor.cancel()
    }
}
