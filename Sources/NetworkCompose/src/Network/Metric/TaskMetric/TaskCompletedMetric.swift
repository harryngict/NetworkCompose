//
//  TaskCompletedMetric.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 23/11/23.
//

import Foundation

public struct TaskCompletedMetric: TaskMetric {
    public var taskType: TaskType
    public var createdAt: Date
    public var originalRequest: RequestMetric
    public var currentRequest: RequestMetric?
    public var response: ResponseMetric?
    public var error: ResponseErrorMetric?
    public var requestBody: Data?
    public var responseBody: Data?

    public init(taskType: TaskType,
                createdAt: Date,
                originalRequest: RequestMetric,
                currentRequest: RequestMetric?,
                response: ResponseMetric?,
                error: ResponseErrorMetric?,
                requestBody: Data?,
                responseBody: Data?)
    {
        self.taskType = taskType
        self.createdAt = createdAt
        self.originalRequest = originalRequest
        self.currentRequest = currentRequest
        self.response = response
        self.error = error
        self.requestBody = requestBody
        self.responseBody = responseBody
    }
}
