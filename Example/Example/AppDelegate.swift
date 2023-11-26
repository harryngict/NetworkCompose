//
//  AppDelegate.swift
//  Example
//
//  Created by Hoang Nguyen on 28/10/23.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        /// Call intial `NetworkHubProvider` make sure the network is always init before go to main screen
        /// This can impact app start up time. But it is very small. We will investigate lafter.
        _ = NetworkHubProvider.shared
        return true
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
