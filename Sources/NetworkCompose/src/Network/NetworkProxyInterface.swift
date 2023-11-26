//
//  NetworkProxyInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

public protocol NetworkProxyInterface: NetworkCoreInterface {
    var reAuthService: ReAuthenticationService? { get }
}
