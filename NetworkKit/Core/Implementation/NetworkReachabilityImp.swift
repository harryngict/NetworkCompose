//
//  NetworkReachabilityImp.swift
//  Core/Implementation
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation
import Network

public class NetworkReachabilityImp: NetworkReachability {
    public static let shared = NetworkReachabilityImp()

    private init() {
        isInternetAvailable = status == .satisfied
    }

    private let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    public var isInternetAvailable: Bool

    public func startMonitoring(completion: @escaping ((Bool) -> Void)) {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let this = self else { return }
            this.status = path.status
            this.isInternetAvailable = this.status == .satisfied
            completion(this.isInternetAvailable)
        }
        let queue = DispatchQueue(label: "com.NetworkKit.NetworkReachabilityImp")
        monitor.start(queue: queue)
    }

    public func stopMonitoring() {
        monitor.cancel()
    }
}
