//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Pallavi on 28.04.23.
//

import Foundation

internal final class FeedItemMapper {
    private struct Root:Decodable {
        var items: [Item]
    }

    private struct Item:Decodable {
          let id: UUID
           let description: String?
           let location: String?
            let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    static var OK_200: Int { return 200 }
    static func map(_ data: Data, _ response: HTTPURLResponse) throws ->  [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invaildData
        }
        return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
    }
}
