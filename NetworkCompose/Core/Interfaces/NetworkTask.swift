//
//  NetworkTask.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

/// A protocol representing a network task.
public protocol NetworkTask: AnyObject {}

extension URLSessionTask: NetworkTask {}
