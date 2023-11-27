//
//  URLSession+InputStream.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

extension URLSession {
    func createHttpBodyStream(fromFileURL fileURL: URL) -> InputStream? {
        guard let inputStream = InputStream(url: fileURL) else {
            return nil
        }

        inputStream.open()

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

        return InputStream(data: data as Data)
    }
}
