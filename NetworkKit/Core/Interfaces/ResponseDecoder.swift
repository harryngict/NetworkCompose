//
//  ResponseDecoder.swift
//  Core/Interfaces
//
//  Created by Hoang Nguyen on 12/11/23.
//

import Foundation

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ type: T.Type, from: Data) throws -> T
}

extension JSONDecoder: ResponseDecoder {}
