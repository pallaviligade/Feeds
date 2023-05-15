//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Pallavi on 05.05.23.
//

import Foundation


public enum CachedFeed {
    case empty
    case found (feed: [LocalFeedImage], timestamp: Date)
}


public protocol FeedStore {
     typealias  RetrivalsResult = Result<CachedFeed, Error>

    typealias DeletionResult = Error?
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Error?
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalCompletion = (RetrivalsResult) -> Void
    
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


