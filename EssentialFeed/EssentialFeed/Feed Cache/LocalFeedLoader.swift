//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 05.05.23.
// it can be called controller or controller boundery or interacter || model controller

import Foundation

private final  class  FeedCachePolicy {
    private let calendar = Calendar(identifier: .gregorian)
    private let currentDate: () -> Date
   
    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
     func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
    
    
}

public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    private let feedCachePolicy: FeedCachePolicy
    
    public init(store: FeedStore,currentDate:@escaping () -> Date )  {
        self.store = store
        self.currentDate = currentDate
        self.feedCachePolicy = FeedCachePolicy(currentDate: self.currentDate)
    }
 
}

extension LocalFeedLoader {
    public typealias saveResult = Error?
    
    public func save(_ item: [FeedImage], completion: @escaping (saveResult) -> Void = { _  in }){
        store.deleteCachedFeed(completion: { [weak  self] error in
            guard let self = self else { return  }
            if let deletionError = error {
                completion(deletionError)
            }else {
                self.cache(item, completion: completion)
            }
        })
    }
    private func cache(_  item:[FeedImage],completion:@escaping (saveResult) -> Void)
    {
        store.insertItem(item.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias loadResult = LoadFeedResult
    public func load(completion completionHandler:@escaping (loadResult) -> Void){
        store.retrival {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completionHandler(.failure(error))
                
            case let .found(feed, timestamp) where self.feedCachePolicy.validate(timestamp):
                completionHandler(.success(feed.toModels()))
                
            case .found,.empty:
                completionHandler(.success([]))
            }
        }
    }
}
extension LocalFeedLoader {
    public func validateCahe() {
        store.retrival { [weak self] result in
            guard let self = self else { return  }
            switch result {
            case .failure:
                self.store.deleteCachedFeed{ _ in  }
            case let .found(feed: _, timestamp: timespam)  where !self.feedCachePolicy.validate(timespam):
                self.store.deleteCachedFeed { _ in }
                break
            case .empty, .found: break
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
