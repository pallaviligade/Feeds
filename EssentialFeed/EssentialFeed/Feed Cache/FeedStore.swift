//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Pallavi on 05.05.23.
//

import Foundation

public protocol FeedStore {
     func deleteCachedFeed(completion: @escaping (Error?) -> Void)
     func insertItem(_ item: [LocalFeedImage], timestamp: Date, completion: @escaping (Error?) -> Void)
}


