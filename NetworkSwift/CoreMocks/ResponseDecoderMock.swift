//
//  ResponseDecoderMock.swift
//  NetworkSwift/CoreMocks
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

public class ResponseDecoderMock: ResponseDecoder {
    public init() {}

    public private(set) var decodeCallCount = 0
    public var decodeHandler: ((Any, Data) throws -> (Any))?
    public func decode<T: Decodable>(_ type: T.Type, from: Data) throws -> T {
        decodeCallCount += 1
        if let decodeHandler = decodeHandler {
            return try decodeHandler(type, from) as! T
        }
        fatalError("decodeHandler returns can't have a default value thus its handler must be set")
    }
}
