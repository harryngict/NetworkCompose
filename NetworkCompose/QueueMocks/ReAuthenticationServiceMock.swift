//
//  ReAuthenticationServiceMock.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

public class ReAuthenticationServiceMock: ReAuthenticationService {
    public init() {}

    public private(set) var reAuthenCallCount = 0
    public var reAuthenHandler: ((@escaping (Result<[String: String], NetworkError>) -> Void) -> Void)?
    public func reAuthen(completion: @escaping (Result<[String: String], NetworkError>) -> Void) {
        reAuthenCallCount += 1
        if let reAuthenHandler = reAuthenHandler {
            reAuthenHandler(completion)
        }
    }
}
