//
//  ReponseModel.swift
//  Example
//
//  Created by Hoang Nguyezn on 28/11/23.
//

import Foundation

struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
}

struct Comment: Codable {
    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
}

struct Photo: Codable {
    let albumId: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}
