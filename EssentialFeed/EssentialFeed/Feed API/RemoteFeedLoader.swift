//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 23.04.23.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader
{
   
   private let client: Httpclient
   private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invaildData
    }
    
   public typealias Result = LoadFeedResult<Error>
    
//    public enum Result: Equatable {
//        case success([FeedItem])
//        case failure(Error)
//    }
    
   public init(url: URL, client: Httpclient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping(Result) -> Void)
    {
        self.client.get(from: url) { [weak self]  result in
            guard self != nil else { return }
            switch result {
            case let .success(data, respose):
                completion(FeedItemMapper.map(data, from: respose))
            case .failour:
                completion(.failure(.connectivity))
            }

        }
    }
    
    
   
   
}




