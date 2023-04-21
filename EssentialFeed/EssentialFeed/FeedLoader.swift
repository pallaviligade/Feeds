//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 21/04/23.
//

import Foundation

enum LoadFeedResult {
  case success([FeedItem])
  case error(Error)
 }

protocol FeedLoader
{
    func load(completion: (LoadFeedResult) -> Void)
}
