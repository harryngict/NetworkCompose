//
//  ClientUploadDelegate.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

final class ClientUploadDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    var uploadProgressHandler: ((Double) -> Void)?
    var uploadCompletionHandler: ((Error?) -> Void)?

    func urlSession(_: URLSession,
                    task _: URLSessionTask,
                    didSendBodyData _: Int64,
                    totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64)
    {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        uploadProgressHandler?(progress)
    }

    func urlSession(_: URLSession,
                    task _: URLSessionTask,
                    didCompleteWithError error: Error?)
    {
        if let error = error {
            uploadCompletionHandler?(error)
        } else {
            uploadCompletionHandler?(nil)
        }
    }
}
