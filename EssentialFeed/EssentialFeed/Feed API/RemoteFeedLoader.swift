//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 23.04.23.
//

import Foundation


public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failour(Error)
}
public protocol Httpclient {
    func get(from url: URL,completion:@escaping (HTTPClientResult) -> Void )
}

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
                    let item = try FeedMapper.map(data, respose)
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

private class FeedMapper {
    static func map(_ data: Data, _ response: HTTPURLResponse) throws ->  [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invaildData
        }
        return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
    }
}

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
