//
//  NetworkReachabilityInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation
import Network

public protocol NetworkReachabilityInterface: AnyObject {
    var isInternetAvailable: Bool { get set }

    func startMonitoring(completion: @escaping (Bool) -> Void)
    func stopMonitoring()
}
