//
//  ClientCredentialContainer.swift
//  Example
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation
import NetworkKit

final class ClientCredentialContainer: NetworkCredentialContainer {
    private var token: String?

    init(token: String? = nil) {
        self.token = token
    }

    func updateCredentials(_ value: Any) {
        token = value as? String
    }

    func getCredentials() -> [String: String] {
        var credentialHeaders = ["x-api-key": OnlineRemoteConfig.shared.apiConfig?.apiKey ?? ""]
        if let token = token {
            credentialHeaders["Authorization"] = "Bearer \(token)"
        }
        return credentialHeaders
    }
}
