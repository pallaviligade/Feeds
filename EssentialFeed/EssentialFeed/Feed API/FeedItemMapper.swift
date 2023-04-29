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
        
        var feed: [FeedItem] {
            return items.map { $0.item }
        }
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
    
   
    
    internal static func map(_ data:Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
        let json = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invaildData)
        }
        let item = json.feed
        return .success(item)
       
    }
}
