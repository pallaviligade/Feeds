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
   public init(url: URL, client: Httpclient) {
        self.client = client
        self.url = url
    }
    public func load() {
        self.client.get(from: url)
    }
    
}
public protocol Httpclient {
    func get(from url: URL)
}
