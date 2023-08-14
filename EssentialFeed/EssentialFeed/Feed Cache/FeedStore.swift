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
     case failure(Error)
}


public protocol FeedStore {
     typealias  RetrivalsResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrivalsResult) -> Void
    
    typealias DeletionResult = Result<Void,Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void,Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
   
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}


