//
//  NetworkCredentialContainer.swift
//  Core/Interfaces
//
//  Created by Hoang Nguyen on 11/11/23.
//

import Foundation

public protocol NetworkCredentialContainer: AnyObject {
    func getCredentials() -> [String: String]
    func updateCredentials(_ value: Any)
}
