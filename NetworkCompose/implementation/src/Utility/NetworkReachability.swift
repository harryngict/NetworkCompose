//
//  NetworkReachability.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 19/11/23.
//

import Foundation
import Network

public final class NetworkReachability: NetworkReachabilityInterface {
  // MARK: Lifecycle

  private init() {
    isInternetAvailable = true
  }

  // MARK: Public

  public static let shared = NetworkReachability()

  public var isInternetAvailable: Bool

  public func startMonitoring(completion: @escaping ((Bool) -> Void)) {
    monitor.pathUpdateHandler = { [weak self] path in
      guard let this = self else { return }
      this.isInternetAvailable = path.status == .satisfied
      completion(this.isInternetAvailable)
    }
    let queue = DispatchQueue(label: "\(LibraryConstant.domain).NetworkReachability")
    monitor.start(queue: queue)
  }

  public func stopMonitoring() {
    monitor.cancel()
  }

  // MARK: Private

  private let monitor = NWPathMonitor()
}
