//
//  NetworkStrategy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

public enum NetworkStrategy {
    case mocker(NetworkExpectationProvider)
    case server
}
