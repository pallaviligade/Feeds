//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Pallavi on 05.05.23.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Error?) -> Void
    
     func deleteCachedFeed(completion: @escaping DeletionCompletion)
     func insertItem(_ item: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
     func retrival(complectionHandler:@escaping RetrievalCompletion)
}


