//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 05.05.23.
//

import Foundation

public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
   public init(store: FeedStore,currentDate:@escaping () -> Date )  {
        self.store = store
        self.currentDate = currentDate
    }
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
    
    public func load(completionHandler:@escaping (LoadFeedResult) -> Void){
        store.retrival { error in
            if let error =  error {
                completionHandler(.failure(error))
            }
           else {
               completionHandler(.success([]))
           }
        }
    }
    
    private func cache(_  item:[FeedImage],completion:@escaping (saveResult) -> Void)
    {
        store.insertItem(item.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
}

private extension Array where Element == FeedImage {
    
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
    }
    
}