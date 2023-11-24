//
//  TaskType.swift
//  NetworkCompose/Core
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

/// An enumeration representing the type of a network task.
public enum TaskType: Codable, CaseIterable, Sendable {
    /// A data task for fetching data.
    case dataTask

    /// A download task for downloading a file.
    case downloadTask

    /// An upload task for sending data to a server.
    case uploadTask

    /// Initializes a `TaskType` based on the provided URLSession task.
    ///
    /// - Parameter task: The URLSession task to determine the type from.
    public init(task: URLSessionTask) {
        switch task {
        case is URLSessionUploadTask: self = .uploadTask
        case is URLSessionDataTask: self = .dataTask
        case is URLSessionDownloadTask: self = .downloadTask
        default: self = .dataTask
        }
    }
}
