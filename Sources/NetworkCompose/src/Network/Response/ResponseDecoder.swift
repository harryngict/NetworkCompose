//
//  ResponseDecoder.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 12/11/23.
//

import Foundation

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: ResponseDecoder {}
