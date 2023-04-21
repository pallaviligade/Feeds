//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 21/04/23.
//

import Foundation

enum Result {
  case success([FeedItem])
  case error(Error)
 }

protocol FeedLoader
{
    func load(completion: () -> Void)
}
