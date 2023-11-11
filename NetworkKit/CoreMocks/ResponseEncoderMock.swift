//
//  ResponseEncoderMock.swift
//  CoreMocks
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation

public class ResponseEncoderMock: ResponseEncoder {
    public init() {}

    public private(set) var encodeCallCount = 0
    public var encodeHandler: ((Any) throws -> (Data))?
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        encodeCallCount += 1
        if let encodeHandler = encodeHandler {
            return try encodeHandler(value)
        }
        fatalError("encodeHandler returns can't have a default value thus its handler must be set")
    }

    public private(set) var encodeToStringCallCount = 0
    public var encodeToStringHandler: ((Any) throws -> (String))?
    public func encodeToString<T: Encodable>(_ value: T) throws -> String {
        encodeToStringCallCount += 1
        if let encodeToStringHandler = encodeToStringHandler {
            return try encodeToStringHandler(value)
        }
        return ""
    }
}
