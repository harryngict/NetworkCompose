//
//  TaskType.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 24/11/23.
//

import Foundation

public enum TaskType: Codable, CaseIterable, Sendable {
  case dataTask

  // MARK: Lifecycle

  public init(task: URLSessionTask) {
    switch task {
    case is URLSessionDataTask: self = .dataTask
    default: self = .dataTask
    }
  }
}
