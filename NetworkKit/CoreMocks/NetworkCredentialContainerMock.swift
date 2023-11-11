//
//  NetworkCredentialContainerMock.swift
//  CoreMocks
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

public class NetworkCredentialContainerMock: NetworkCredentialContainer {
    public init() {}

    public private(set) var getCredentialsCallCount = 0
    public var getCredentialsHandler: (() -> ([String: String]))?
    public func getCredentials() -> [String: String] {
        getCredentialsCallCount += 1
        if let getCredentialsHandler = getCredentialsHandler {
            return getCredentialsHandler()
        }
        return [String: String]()
    }

    public private(set) var updateCredentialsCallCount = 0
    public var updateCredentialsHandler: ((Any) -> Void)?
    public func updateCredentials(_ value: Any) {
        updateCredentialsCallCount += 1
        if let updateCredentialsHandler = updateCredentialsHandler {
            updateCredentialsHandler(value)
        }
    }
}
