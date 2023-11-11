//
//  ReAuthenticationServiceMock.swift
//  NetworkQueueMocks
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

public class ReAuthenticationServiceMock: ReAuthenticationService {
    public init() {}

    public private(set) var executeCallCount = 0
    public var executeHandler: ((@escaping (Result<Void, NetworkError>) -> Void) -> Void)?
    public func execute(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        executeCallCount += 1
        if let executeHandler = executeHandler {
            executeHandler(completion)
        }
    }
}
