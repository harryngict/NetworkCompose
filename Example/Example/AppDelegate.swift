//
//  AppDelegate.swift
//  Example
//
//  Created by Hoang Nguyen on 28/10/23.
//

import Firebase
import FirebaseRemoteConfig
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        FirebaseApp.configure()
        OnlineRemoteConfig.shared.fetchFeatureFlag { error in
            guard let error = error else {
                return
            }
            debugPrint("OnlineRemoteConfig error: \(String(describing: error.localizedDescription))")
        }
        return true
    }
}
