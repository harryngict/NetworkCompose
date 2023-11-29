//
//  NetworkTask.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

public protocol NetworkTask: AnyObject {
    func cancel()
}

extension URLSessionTask: NetworkTask {}
