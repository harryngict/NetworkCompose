//
//  NetworkTask.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 18/11/23.
//

import Foundation

// MARK: - NetworkTask

/// @mockable
public protocol NetworkTask: AnyObject {
  /// Cancels the network task.
  func cancel()
}

// MARK: - URLSessionTask + NetworkTask

extension URLSessionTask: NetworkTask {}
