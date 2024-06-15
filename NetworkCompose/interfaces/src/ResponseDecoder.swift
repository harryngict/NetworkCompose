//
//  ResponseDecoder.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 12/11/23.
//

import Foundation

// MARK: - ResponseDecoder

/// @mockable
public protocol ResponseDecoder {
  /// Decodes the specified type from the provided data.
  ///
  /// - Parameters:
  ///   - type: The type to decode.
  ///   - data: The data to decode from.
  /// - Returns: An instance of the specified type.
  /// - Throws: An error if the decoding process fails.
  func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

// MARK: - JSONDecoder + ResponseDecoder

extension JSONDecoder: ResponseDecoder {}
