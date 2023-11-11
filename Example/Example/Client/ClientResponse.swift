//
//  ClientResponse.swift
//  Example
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation

struct ClientResponse: Codable {
    let data: [Model]

    struct Model: Codable {
        let id: String
    }
}
