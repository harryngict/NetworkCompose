//
//  OperationQueueManagerInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

public protocol OperationQueueManagerInterface: AnyObject {
    var operationQueue: OperationQueue { get }
    func enqueue(_ operation: Operation)
}