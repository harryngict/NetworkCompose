//
//  URLRequest+Extensions.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

extension URLRequest {
    func httpBodyStreamData() -> Data? {
        guard let bodyStream = httpBodyStream else {
            return nil
        }

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        bodyStream.open()
        defer {
            buffer.deallocate()
            bodyStream.close()
        }

        var bodyStreamData = Data()
        while bodyStream.hasBytesAvailable {
            let readData = bodyStream.read(buffer, maxLength: bufferSize)
            bodyStreamData.append(buffer, count: readData)
        }

        return bodyStreamData
    }
}
