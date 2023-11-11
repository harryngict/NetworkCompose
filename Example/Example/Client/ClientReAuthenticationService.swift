//
//  ClientReAuthenticationService.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation
import NetworkKit

final class ClientReAuthenticationService: ReAuthenticationService {
    private var credentialContainer: NetworkCredentialContainer

    init(credentialContainer: NetworkCredentialContainer) {
        self.credentialContainer = credentialContainer
    }

    func execute(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        /// For testing now. Infact this value should get from real service
        credentialContainer.updateCredentials("newToken")
        completion(.success(()))
    }
}
