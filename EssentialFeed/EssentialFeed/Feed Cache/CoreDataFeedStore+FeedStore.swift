//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Pallavi on 08.08.23.
//

import CoreData

extension CoreDataFeedStore: FeedStore {

//    public func retrieve(completion: @escaping RetrievalCompletion) {
//        perform { context in
//            completion(Result {
//                try ManagedCache.find(in: context).map {
//                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
//                }
//            })
//        }
//    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
            perform { context in
                do {
                    if let cache = try ManagedCache.find(in: context) {
                       // completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
                        completion(.success(.found(feed: cache.localFeed, timestamp: cache.timestamp)))
                    } else {
                        completion(.success(.empty))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }

}
