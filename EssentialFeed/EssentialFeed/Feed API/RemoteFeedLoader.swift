//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 23.04.23.
//

import Foundation

public protocol Httpclient {
    func get(from url: URL,completion:@escaping (Error) -> Void )
}

public final class RemoteFeedLoader
{
   private let client: Httpclient
   private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        
    }
   public init(url: URL, client: Httpclient) {
        self.client = client
        self.url = url
    }
    public func load(completion: @escaping(Error) -> Void = { _ in }) {
        self.client.get(from: url) { error in
            completion(.connectivity)
        }
    }
    
}

