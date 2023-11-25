//
//  NetworkMetricInterceptor.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public protocol NetworkMetricInterceptor {
    func sendEvent(_ event: NetworkTaskEvent)
}
