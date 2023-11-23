//
//  URLRequest+Extensions.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

extension URLRequest {
    /// Reads the data from the `httpBodyStream` property of the URLRequest.
    ///
    /// This method opens the `httpBodyStream`, reads the data in chunks, and appends it to a `Data` object.
    /// After reading the entire stream, it closes the stream and returns the accumulated data.
    ///
    /// - Returns: The data read from the `httpBodyStream`, or `nil` if the stream is not available.
    func httpBodyStreamData() -> Data? {
        guard let bodyStream = httpBodyStream else {
            return nil
        }

        // Buffer size for reading stream data.
        let bufferSize = 1024
        // Allocate a buffer for reading stream data.
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

        // Open the body stream.
        bodyStream.open()
        // Ensure that the buffer is deallocated and the stream is closed when leaving the scope.
        defer {
            buffer.deallocate()
            bodyStream.close()
        }

        // Accumulate the stream data.
        var bodyStreamData = Data()
        while bodyStream.hasBytesAvailable {
            let readData = bodyStream.read(buffer, maxLength: bufferSize)
            bodyStreamData.append(buffer, count: readData)
        }

        return bodyStreamData
    }
}
