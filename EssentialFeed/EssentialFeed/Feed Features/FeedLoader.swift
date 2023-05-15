//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 21/04/23.
//

import Foundation


public typealias LoadFeedResult = Result<[FeedImage], Error> 

//extension LoadFeedResult:Equatable where Error: Equatable { // This Generic
//
//}

protocol FeedLoader
{
    func load(completion:@escaping (LoadFeedResult) -> Void)
}
