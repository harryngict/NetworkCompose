//
//  ContentTypeMetric.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

/// A struct representing the content type of a network request or response.
public struct ContentTypeMetric: Hashable, ExpressibleByStringLiteral {
    /// The type and subtype of the content type. This is everything except for
    /// any parameters that are also attached.
    public var type: String

    /// Key/Value pairs serialized as parameters for the content type.
    ///
    /// For example, in "`text/plain; charset=UTF-8`" "charset" is
    /// the name of a parameter with the value "UTF-8".
    public var parameters: [String: String]

    /// The raw value of the content type.
    public var rawValue: String

    /// Initializes a `ContentTypeMetric` instance based on a raw content type string.
    ///
    /// - Parameter rawValue: The raw content type string.
    public init?(rawValue: String) {
        let parts = rawValue.split(separator: ";")
        guard let type = parts.first else { return nil }
        self.type = type.lowercased()
        var parameters: [String: String] = [:]
        for (key, value) in parts.dropFirst().compactMap(ContentTypeMetric.parseParameter) {
            parameters[key] = value
        }
        self.parameters = parameters
        self.rawValue = rawValue
    }

    /// A predefined `ContentTypeMetric` representing any content type.
    public static let any = ContentTypeMetric(rawValue: "*/*")!

    /// Initializes a `ContentTypeMetric` instance based on a string literal.
    ///
    /// - Parameter value: The string literal representing the content type.
    public init(stringLiteral value: String) {
        self = ContentTypeMetric(rawValue: value) ?? .any
    }

    /// Checks if the content type is JSON.
    public var isJSON: Bool { type.contains("json") }

    /// Checks if the content type is PDF.
    public var isPDF: Bool { type.contains("pdf") }

    /// Checks if the content type represents an image.
    public var isImage: Bool { type.hasPrefix("image/") }

    /// Checks if the content type is HTML.
    public var isHTML: Bool { type.contains("html") }

    /// Checks if the content type is an encoded form.
    public var isEncodedForm: Bool { type == "application/x-www-form-urlencoded" }

    private static func parseParameter(_ param: Substring) -> (String, String)? {
        let parts = param.split(separator: "=")
        guard parts.count == 2, let name = parts.first, let value = parts.last else {
            return nil
        }
        return (name.trimmingCharacters(in: .whitespaces), value.trimmingCharacters(in: .whitespaces))
    }
}
