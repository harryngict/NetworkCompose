//
//  NetworkBuilder.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 24/11/23.
//

import Foundation
import NetworkCompose

// MARK: - NetworkBuilder

public class NetworkBuilder<SessionType: NetworkSession>: NetworkBuilderSettings<SessionType> {
  // MARK: Public

  /// Sets the re-authentication service for the builder.
  ///
  /// - Parameter reAuthService: The service responsible for re-authentication.
  /// - Returns: The builder instance for method chaining.
  @discardableResult
  public func reAuthenService(_ reAuthService: ReAuthenticationService?) -> Self {
    self.reAuthService = reAuthService
    return self
  }

  /// Resets the configuration of the network builder and its related properties to their default state.
  ///
  /// This method clears any custom re-authentication service, operation queue, SSL pinning policy,
  /// metric interceptor, network strategy, and sets default values for execution and observation queues,
  /// and network reachability.
  ///
  /// - Returns: The modified instance of the network builder with the default configuration.
  @discardableResult
  override public func setDefaultConfiguration() -> Self {
    reAuthService = nil
    _ = super.setDefaultConfiguration()
    return self
  }

  /// Clears mock data in the disk storage.
  ///
  /// This method is used to remove any mock data stored in the disk storage. It creates a `StorageServiceProvider`
  /// with the provided logger and executes the operation asynchronously on the specified queue.
  ///
  /// - Returns: An instance of the same type to support method chaining.
  @discardableResult
  public func clearStoredMockData() -> Self {
    let provider = StorageServiceDecorator(
      loggerInterface: getLogger(),
      executionQueue: executionQueue)
    try? provider.clearMockDataInDisk()
    return self
  }

  /// Builds and returns an instance conforming to `NetworkRouterInterface` based on the configured strategies.
  ///
  /// This method creates either a `NetworkNavigator` or a `NetworkMocker` based on the specified strategies.
  ///
  /// - Returns: An instance conforming to `NetworkRouterInterface`.
  public func build() -> NetworkRouterInterface {
    if case let .enabled(dataType) = automationMode {
      return NetworkAutomationMocker(
        baseURL: baseURL,
        session: session,
        reAuthService: reAuthService,
        executionQueue: executionQueue,
        observationQueue: observationQueue,
        loggerInterface: getLogger(),
        dataType: dataType)
    } else {
      return NetworkRouter(
        baseURL: baseURL,
        session: session,
        circuitBreaker: circuitBreaker,
        reAuthService: reAuthService,
        networkReachability: networkReachability,
        executionQueue: executionQueue,
        observationQueue: observationQueue,
        storageService: getStorageService(),
        loggerInterface: getLogger())
    }
  }

  // MARK: Private

  /// The service responsible for re-authentication.
  private var reAuthService: ReAuthenticationService?
}

private extension NetworkBuilder {
  func getStorageService() -> StorageServiceInterface? {
    switch recordResponseMode {
    case .disabled: return nil
    case .enabled:
      return StorageServiceDecorator(
        loggerInterface: getLogger(),
        executionQueue: executionQueue)
    }
  }
}
