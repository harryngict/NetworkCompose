//
//  DispatchQueueType.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 23/11/23.
//

import Foundation

// MARK: - DispatchQueueType

public protocol DispatchQueueType {
  func async(work: @escaping () -> Void)
  func asyncAfter(deadline: DispatchTime, work: @escaping () -> Void)
}

// MARK: - DispatchQueue + DispatchQueueType

extension DispatchQueue: DispatchQueueType {
  public func async(work: @escaping () -> Void) {
    async(execute: work)
  }

  public func asyncAfter(deadline: DispatchTime, work: @escaping () -> Void) {
    asyncAfter(deadline: deadline, execute: work)
  }
}

// MARK: - DefaultDispatchQueue

public enum DefaultDispatchQueue: Sendable {
  public static let executionQueue: DispatchQueueType = DispatchQueue(
    label: "\(LibraryConstant.domain).DefaultDispatchQueue",
    qos: .userInitiated,
    attributes: .concurrent)
  public static let observationQueue: DispatchQueueType = DispatchQueue.main
}
