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
    
   public typealias Result = LoadFeedResult
    
//    public enum Result: Equatable {
//        case success([FeedImage])
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
                completion(RemoteFeedLoader.map(data, respose: respose))
            case .failure:
                completion(.failure(Error.connectivity))
            }

        }
    }
    
    
    private static func map(_ data:Data, respose:HTTPURLResponse) -> Result {
        do {
            let json =  try FeedItemMapper.map(data, from: respose)
             return (.success(json.toModel()))
        }catch {
            return (.failure(error))
        }
    }
    
   
   
}

extension Array where Element ==  RemoteFeedItem {
    func toModel() -> [FeedImage] {
        return map({ FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)})
    }
}




