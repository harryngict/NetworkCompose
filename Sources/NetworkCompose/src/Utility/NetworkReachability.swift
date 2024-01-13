//
//  NetworkReachability.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 19/11/23.
//

import Foundation
import Network

public final class NetworkReachability: NetworkReachabilityInterface {
    public static let shared = NetworkReachability()

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
        let queue = DispatchQueue(label: "\(LibraryConstant.domain).NetworkReachability")
        monitor.start(queue: queue)
    }

    public func stopMonitoring() {
        monitor.cancel()
    }
}
