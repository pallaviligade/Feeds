//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Pallavi on 05.05.23.
//

import Foundation

public enum  RetrivalsCachedFeedResult{
    case empty
    case found (feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrivalsCachedFeedResult) -> Void
    
    /// The completion handler can be invoked in any thread.
        /// Clients are responsible to dispatch to appropriate threads, if needed.
     func deleteCachedFeed(completion: @escaping DeletionCompletion)
    /// The completion handler can be invoked in any thread.
        /// Clients are responsible to dispatch to appropriate threads, if needed.
     func insertItem(_ item: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    /// The completion handler can be invoked in any thread.
        /// Clients are responsible to dispatch to appropriate threads, if needed.
     func retrival(complectionHandler:@escaping RetrievalCompletion)
}


