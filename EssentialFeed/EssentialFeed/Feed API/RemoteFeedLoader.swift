//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 23.04.23.
//

import Foundation

public final class RemoteFeedLoader
{
   private let client: Httpclient
   private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invaildData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
   public init(url: URL, client: Httpclient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping(Result) -> Void)
    {
        self.client.get(from: url) { result in
            switch result {
            case let .success(data, respose):
                do{
                    let item = try FeedItemMapper.map(data, respose)
                    completion(.success(item))
                } catch {
                    completion(.failure(.invaildData))
                }
            case .failour:
                completion(.failure(.connectivity))
            }

        }
    }
}




