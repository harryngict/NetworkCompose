//
//  TaskType.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public enum TaskType: Codable, CaseIterable, Sendable {
    case dataTask
    case downloadTask
    case uploadTask

    public init(task: URLSessionTask) {
        switch task {
        case is URLSessionUploadTask: self = .uploadTask
        case is URLSessionDataTask: self = .dataTask
        case is URLSessionDownloadTask: self = .downloadTask
        default: self = .dataTask
        }
    }
}
