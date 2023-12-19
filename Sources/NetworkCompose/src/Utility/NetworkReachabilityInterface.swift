//
//  NetworkReachabilityInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 19/11/23.
//

import Foundation
import Network

public protocol NetworkReachabilityInterface: AnyObject {
    /// A Boolean value indicating whether the internet is currently available.
    var isInternetAvailable: Bool { get set }

    /// Starts monitoring the network reachability and provides a completion handler with the current internet availability status.
    ///
    /// - Parameter completion: A closure that receives a Boolean value indicating whether the internet is available.
    func startMonitoring(completion: @escaping (Bool) -> Void)

    /// Stops monitoring the network reachability.
    func stopMonitoring()
}
