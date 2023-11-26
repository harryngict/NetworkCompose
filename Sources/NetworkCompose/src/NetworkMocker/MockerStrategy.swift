//
//  MockerStrategy.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 25/11/23.
//

import Foundation

public enum MockerStrategy {
    case custom(NetworkMockerProvider)
    case localStorage(StorageStrategy)
}
