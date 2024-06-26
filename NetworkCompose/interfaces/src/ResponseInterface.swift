//
//  ResponseInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 11/11/23.
//

import Foundation

/// @mockable
public protocol ResponseInterface {
  /// The  status code of the response.
  var statusCode: Int { get }

  /// The data received in the response.
  var data: Data { get }
}
