//
//  ReAuthenticationService.swift
//  NetworkQueue/Interfaces
//
//  Created by Hoang Nguyen on 17/11/23.
//

import Foundation

public protocol ReAuthenticationService: AnyObject {
    func execute(completion: @escaping (Result<Void, NetworkError>) -> Void)
}
