//
//  NetworkTask.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 18/11/23.
//

import Foundation

public protocol NetworkTask: AnyObject {
    /// Cancels the network task.
    func cancel()
}

extension URLSessionTask: NetworkTask {}
