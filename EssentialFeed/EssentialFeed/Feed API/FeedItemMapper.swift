//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Pallavi on 28.04.23.
//

import Foundation




internal final class FeedItemMapper
{
    private struct Root:Decodable {
        var items: [RemoteFeedItem]
    }
    
   

   
    static var OK_200: Int { return 200 }
    
   
    
    internal static func map(_ data:Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
        let json = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invaildData
        }
       
        return json.items
       
    }
}
