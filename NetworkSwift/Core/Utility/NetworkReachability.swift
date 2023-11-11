//
//  NetworkReachability.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation
import Network

/// A protocol defining the interface for monitoring network reachability.
public protocol NetworkReachability: AnyObject {
    /// A boolean indicating whether internet connectivity is available.
    var isInternetAvailable: Bool { get set }

    /// Starts monitoring network reachability and provides updates via a completion handler.
    /// - Parameter completion: A closure to be called with the current reachability status.
    func startMonitoring(completion: @escaping (Bool) -> Void)

    /// Stops monitoring network reachability.
    func stopMonitoring()
}
