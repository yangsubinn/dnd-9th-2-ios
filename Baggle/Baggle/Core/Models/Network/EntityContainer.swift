//
//  EntityContainer.swift
//  Baggle
//
//  Created by youtak on 2023/08/09.
//

import Foundation

struct EntityContainer<T> {
    let status: Int
    let message: String
    let data: T
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case data
    }
}

extension EntityContainer: Decodable where T: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Int.self, forKey: .status)
        message = try container.decode(String.self, forKey: .message)
        data = try container.decode(T.self, forKey: .data)
    }
}
