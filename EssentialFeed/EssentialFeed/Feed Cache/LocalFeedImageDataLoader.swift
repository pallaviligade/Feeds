//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 03.08.23.
//

import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    private final class Task: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
         func complete(with result: FeedImageDataLoader.Result) {
            self.completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
                    completion = nil
        }
        }
   
    
    public enum Error: Swift.Error {
            case failed
            case notFound
    }
    
    
    
    public func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void ) -> FeedImageDataLoaderTask {
        
        
        let task = Task(completion: completionHandler)
        
        store.retrieve(dataForUrl: url) { [weak self]  result in
            guard  self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.failed}
                .flatMap { data in data.map{.success($0)} ?? .failure(Error.notFound) }
            )
        }
        return task
    }
}
