//
//  Article.swift
//  Example
//
//  Created by Hoang Nguyen on 19/11/23.
//

import Foundation

struct Article: Codable, Hashable {
    let id: Int
    let title: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id, title, name
    }
}
