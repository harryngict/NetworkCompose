//
//  ResponseEncoder.swift
//  Core/Interfaces
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation

public protocol ResponseEncoder {
    func encode<T: Encodable>(_ value: T) throws -> Data
    func encodeToString<T: Encodable>(_ value: T) throws -> String
}

extension JSONEncoder: ResponseEncoder {
    public func encodeToString<T: Encodable>(_ value: T) throws -> String {
        outputFormatting = .prettyPrinted
        let jsonData = try encode(value)
        return String(data: jsonData, encoding: .utf8) ?? ""
    }
}
