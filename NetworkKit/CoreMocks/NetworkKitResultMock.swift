//
//  NetworkKitResultMock.swift
//  CoreMocks
//
//  Created by Hoang Nguyen on 18/11/23.
//

import Foundation

public enum NetworkKitResultMock {
    case failure(NetworkError)
    case requestSuccess(NetworkResponse)
    case uploadSuccess(NetworkResponse)
    case downloadSuccess(URL)
}
