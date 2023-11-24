//
//  ResponseDecoder.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 12/11/23.
//

import Foundation

/// A protocol defining the interface for response decoders.
public protocol ResponseDecoder {
    /// Decodes an instance of the specified type from the given data.
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - data: The data to decode from.
    /// - Returns: An instance of the specified type.
    /// - Throws: An error if decoding fails.
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

/// An extension that makes `JSONDecoder` conform to the `ResponseDecoder` protocol.
extension JSONDecoder: ResponseDecoder {}
