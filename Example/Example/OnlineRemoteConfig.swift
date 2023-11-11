//
//  OnlineRemoteConfig.swift
//  Example
//
//  Created by Hoang Nguyen on 19/11/23.
//

import FirebaseRemoteConfig
import Foundation

final class OnlineRemoteConfig {
    struct ApiConfig {
        let apiKey: String
        let baseURL: String
        let path: String
    }

    private let remoteConfig: RemoteConfig
    public static let shared = OnlineRemoteConfig()
    public var apiConfig: ApiConfig?

    private init(remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()) {
        self.remoteConfig = remoteConfig
    }

    func fetchFeatureFlag(completion: @escaping ((Error?) -> Void)) {
        remoteConfig.fetch(withExpirationDuration: 3600) { [weak self] status, error in
            guard let this = self else { return }
            if status == .success {
                this.remoteConfig.activate { _, _ in
                    this.applyRemoteConfigValues()
                    completion(nil)
                }
            } else {
                completion(error)
            }
        }
    }
}

private extension OnlineRemoteConfig {
    func applyRemoteConfigValues() {
        guard let apiKey = remoteConfig["api_key"].stringValue,
              let baseURL = remoteConfig["base_url"].stringValue,
              let path = remoteConfig["path_url"].stringValue
        else {
            return
        }
        apiConfig = ApiConfig(apiKey: apiKey, baseURL: baseURL, path: path)
    }
}
