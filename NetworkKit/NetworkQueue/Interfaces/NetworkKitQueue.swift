//
//  NetworkKitQueue.swift
//  NetworkQueue/Interfaces
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

public protocol NetworkKitQueue: AnyObject {
    var reAuthService: ReAuthenticationService { get }

    func request<RequestType: NetworkRequest>(
        _ request: RequestType,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    )
}
