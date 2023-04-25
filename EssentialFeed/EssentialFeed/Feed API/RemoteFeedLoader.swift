//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 23.04.23.
//

import Foundation

public protocol Httpclient {
    func get(from url: URL,completion:@escaping (Error?, HTTPURLResponse?) -> Void )
}

public final class RemoteFeedLoader
{
   private let client: Httpclient
   private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invaildData
        
    }
   public init(url: URL, client: Httpclient) {
        self.client = client
        self.url = url
    }
    public func load(completion: @escaping(Error) -> Void) {
        self.client.get(from: url) { error, response in
            completion(.connectivity)
        }
    }
    
}

