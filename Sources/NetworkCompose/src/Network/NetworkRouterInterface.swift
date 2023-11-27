//
//  NetworkRouterInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 28/11/23.
//

import Foundation

/// A protocol representing a network coordinator with additional authentication features.
///
/// Inherits from `NetworkSessionExecutorInteface` and includes a property for re-authentication service.
public protocol NetworkRouterInterface: NetworkSessionExecutorInteface {
    /// An optional re-authentication service that can be used for refreshing authentication tokens.
    var reAuthService: ReAuthenticationService? { get }
}
