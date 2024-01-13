//
//  NetworkRouterInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 28/11/23.
//

import Foundation

public protocol NetworkRouterInterface: NetworkSessionExecutorInteface {
    /// An optional re-authentication service that can be used for refreshing authentication tokens.
    var reAuthService: ReAuthenticationService? { get }
}
