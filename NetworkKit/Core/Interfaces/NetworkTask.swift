//
//  NetworkTask.swift
//  Core/Interfaces
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

public protocol NetworkTask: AnyObject {}

extension URLSessionDataTask: NetworkTask {}

extension URLSessionDownloadTask: NetworkTask {}
