//
//  NetworkTask.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

/// A protocol representing a network task.
public protocol NetworkTask: AnyObject {}

extension URLSessionDataTask: NetworkTask {}

extension URLSessionDownloadTask: NetworkTask {}
