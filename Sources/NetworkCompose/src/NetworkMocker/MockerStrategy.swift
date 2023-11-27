//
//  MockerStrategy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

public enum MockerStrategy {
    case disabled
    case enabled(DataType)

    public enum DataType {
        case custom(EndpointExpectationProvider)
        case local
    }
}
