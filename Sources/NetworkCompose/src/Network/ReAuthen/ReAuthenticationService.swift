//
//  ReAuthenticationService.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 17/11/23.
//

import Foundation

public protocol ReAuthenticationService: AnyObject {
    /// Initiates the re-authentication process.
    ///
    /// - Parameter completion: A closure called when the re-authentication process is completed.
    ///   - result: A result indicating the success or failure of the re-authentication.
    func reAuthen(completion: @escaping (Result<[String: String], NetworkError>) -> Void)
}
