//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 05.05.23.
// it can be called controller or controller boundery or interacter || model controller

import Foundation



public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
   
    
    public init(store: FeedStore,currentDate:@escaping () -> Date )  {
        self.store = store
        self.currentDate = currentDate
        
    }
 
}

extension LocalFeedLoader {
    public typealias saveResult = Result<Void, Error>
    
    public func save(_ item: [FeedImage], completion: @escaping (saveResult) -> Void = { _  in }){
        store.deleteCachedFeed(completion: { [weak  self] deletionResult in
            
            guard let self = self else { return  }
            switch deletionResult {
            case .success:
                self.cache(item, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
    private func cache(_  item:[FeedImage],completion:@escaping (saveResult) -> Void)
    {
        store.insert(item.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias loadResult = FeedLoader.Result
    
    public func load(completion completionHandler:@escaping (loadResult) -> Void){
        store.retrieve {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completionHandler(.failure(error))
                
            case let .success((.found(feed, timestamp))) where FeedCachePolicy.validate(timestamp,against: self.currentDate()):
                completionHandler(.success(feed.toModels()))
                
            case .success:
                completionHandler(.success([]))
            }
        }
    }
}
extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
        public func validateCache(completion: @escaping (ValidationResult) -> Void) {
            store.retrieve { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .failure:
                    self.store.deleteCachedFeed(completion: completion)
print("deleteCachedFeed is need to implement")
//                case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
//                    self.store.deleteCachedFeed(completion: completion)

                case .success:
                    completion(.success(()))
                }
            }
        }
}

private extension Array where Element == FeedImage {
    
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
    }
    
}
private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}
