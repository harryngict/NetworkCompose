//
//  URLSession+BodyStream.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

extension URLSession {
    /// Creates an HTTP body stream from a file URL.
    ///
    /// This method takes a file URL and returns an `InputStream` that can be used as the HTTP body in a URL request.
    ///
    /// - Parameters:
    ///   - fileURL: The file URL from which the input stream is created.
    ///
    /// - Returns: An `InputStream` instance if successful, or `nil` if the input stream couldn't be created.
    func createHttpBodyStream(fromFileURL fileURL: URL) -> InputStream? {
        // Open an input stream from the given file URL
        guard let inputStream = InputStream(url: fileURL) else {
            return nil
        }

        inputStream.open()

        // Read data from the input stream into a buffer
        var buffer = [UInt8](repeating: 0, count: 1024)

        let data = NSMutableData()

        while inputStream.hasBytesAvailable {
            let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
            if bytesRead > 0 {
                data.append(buffer, length: bytesRead)
            } else {
                break
            }
        }
        inputStream.close()

        // Create a new input stream from the read data
        return InputStream(data: data as Data)
    }
}
