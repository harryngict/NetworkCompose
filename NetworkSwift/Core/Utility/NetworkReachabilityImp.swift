//
//  NetworkReachabilityImp.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation
import Network

/// A class responsible for monitoring network reachability.
public final class NetworkReachabilityImp: NetworkReachability {
    /// A shared instance of the `NetworkReachabilityImp`.
    public static let shared = NetworkReachabilityImp()

    /// The network path monitor.
    private let monitor = NWPathMonitor()

    /// A boolean indicating whether there is an active internet connection.
    public var isInternetAvailable: Bool

    /// Initializes the `NetworkReachabilityImp` and sets the initial internet availability.
    private init() {
        isInternetAvailable = true
    }

    /// Starts monitoring the network path and calls the provided completion handler
    /// when the network status changes.
    ///
    /// - Parameter completion: A closure to be called with the updated internet availability status.
    public func startMonitoring(completion: @escaping ((Bool) -> Void)) {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let this = self else { return }
            this.isInternetAvailable = path.status == .satisfied
            completion(this.isInternetAvailable)
        }
        let queue = DispatchQueue(label: "com.NetworkSwift.NetworkReachabilityImp")
        monitor.start(queue: queue)
    }

    /// Stops monitoring the network path.
    public func stopMonitoring() {
        monitor.cancel()
    }
}
