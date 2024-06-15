//
//  Response.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 11/11/23.
//

import Foundation
import NetworkCompose

struct Response: ResponseInterface, Sendable {
  // MARK: Lifecycle

  init(statusCode: Int, data: Data) {
    self.statusCode = statusCode
    self.data = data
  }

  // MARK: Internal

  let statusCode: Int
  let data: Data
}
