//
//  ClientReAuthenticationService.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation
import NetworkSwift

/// A service responsible for handling client re-authentication.
///
/// This service is used to perform client re-authentication and retrieve a new JWT token.
///
/// ## Usage
/// ```swift
/// let reAuthService = ClientReAuthenticationService()
/// reAuthService.reAuthen { result in
///     switch result {
///     case .success(let tokenInfo):
///         // Handle successful re-authentication
///         print("New JWT token: \(tokenInfo["jwt_token"] ?? "")")
///     case .failure(let error):
///         // Handle re-authentication failure
///         print("Re-authentication failed with error: \(error.localizedDescription)")
///     }
/// }
/// ```
final class ClientReAuthenticationService: ReAuthenticationService {
    /// Initializes the `ClientReAuthenticationService`.
    init() {}

    /// Initiates the client re-authentication process.
    ///
    /// - Parameter completion: The completion handler to be called when the re-authentication is complete.
    ///                         It provides a result indicating success with the new token or failure with an error.
    ///
    /// - Note: This implementation is for testing purposes. In a production environment, this method should interact
    ///         with the actual re-authentication service to obtain a new token.
    func reAuthen(completion: @escaping (Result<[String: String], NetworkSwift.NetworkError>) -> Void) {
        // For testing now. In fact, this value should get `newtoken` from the real service
        completion(.success(["jwt_token": "newtoken"]))
    }
}
