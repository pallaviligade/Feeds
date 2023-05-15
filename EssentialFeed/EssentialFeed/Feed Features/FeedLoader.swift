//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 21/04/23.
//

import Foundation




//extension LoadFeedResult:Equatable where Error: Equatable { // This Generic
//
//}

public protocol FeedLoader
{
     typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion:@escaping (Result) -> Void)
}
