//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 21/04/23.
//

import Foundation

public enum LoadFeedResult {
  case success([FeedItem])
  case failure(Error)
 }

//extension LoadFeedResult:Equatable where Error: Equatable { // This Generic
//
//}

protocol FeedLoader
{
    associatedtype Error: Swift.Error
    func load(completion:@escaping (LoadFeedResult) -> Void)
}
