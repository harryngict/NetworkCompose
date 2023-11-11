//
//  ClientDownloadDelegate.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

final class ClientDownloadDelegate: NSObject, URLSessionDownloadDelegate {
    var downloadProgressHandler: ((Double) -> Void)?
    var downloadCompletionHandler: ((URL?, Error?) -> Void)?

    func urlSession(_: URLSession,
                    downloadTask _: URLSessionDownloadTask,
                    didWriteData _: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64)
    {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        downloadProgressHandler?(progress)
    }

    func urlSession(_: URLSession,
                    downloadTask _: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL)
    {
        downloadCompletionHandler?(location, nil)
    }
}
