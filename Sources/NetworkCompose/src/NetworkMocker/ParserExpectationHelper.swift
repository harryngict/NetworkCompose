//
//  ParserExpectationHelper.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 26/11/23.
//

import Foundation

/// A helper class for parsing data and creating service expectations.
public final class ParserExpectationHelper {
    public static let shared = ParserExpectationHelper()

    private init() {}

    /// Parse service expectations from raw data.
    ///
    /// - Parameters:
    ///   - data: The raw data to be parsed.
    ///   - responseDecoder: The decoder to be used for decoding the data.
    ///   - type: The type of the expected Decodable response.
    ///   - serviceName: The name of the service.
    ///   - path: The path of the service.
    ///   - method: The HTTP method of the service.
    ///
    /// - Throws: An error if parsing or decoding fails.
    ///
    /// - Returns: A `ServiceExpectation` based on the parsed data.
    public func parseExpections(
        from data: Data,
        responseDecoder: ResponseDecoder,
        type: Decodable.Type,
        serviceName: String,
        path: String,
        method: NetworkMethod
    ) throws -> EndpointExpectation {
        let model = try responseDecoder.decode(type, from: data)
        return EndpointExpectation(name: serviceName,
                                   path: path,
                                   method: method,
                                   response: .successResponse(model))
    }

    /// Parse service expectations from a file.
    ///
    /// - Parameters:
    ///   - filePath: The URL of the file containing raw data.
    ///   - responseDecoder: The decoder to be used for decoding the data.
    ///   - type: The type of the expected Decodable response.
    ///   - serviceName: The name of the service.
    ///   - path: The path of the service.
    ///   - method: The HTTP method of the service.
    ///
    /// - Throws: An error if parsing, decoding, or file reading fails.
    ///
    /// - Returns: A `ServiceExpectation` based on the parsed data.
    public func parseExpections(
        from filePath: URL,
        responseDecoder: ResponseDecoder,
        type: Decodable.Type,
        serviceName: String,
        path: String,
        method: NetworkMethod
    ) throws -> EndpointExpectation {
        let data = try Data(contentsOf: filePath)
        return try parseExpections(from: data,
                                   responseDecoder: responseDecoder,
                                   type: type,
                                   serviceName: serviceName,
                                   path: path,
                                   method: method)
    }
}
