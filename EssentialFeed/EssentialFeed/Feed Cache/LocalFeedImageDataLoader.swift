//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 03.08.23.
//

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader {
    
    public enum loadError: Swift.Error {
        case failed
        case notFound
    }
    
    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        
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
        
    public func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void ) -> FeedImageDataLoaderTask {
        
        
        let task = LoadImageDataTask(completion: completionHandler)
        
        store.retrieve(dataForUrl: url) { [weak self]  result in
            guard  self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in loadError.failed}
                .flatMap { data in data.map{.success($0)} ?? .failure(loadError.notFound) }
            )
        }
        return task
    }
    
}



extension LocalFeedImageDataLoader {
    public typealias SaveResult = Result <Void, Swift.Error>
    
    public enum SaveError: Error {
        case failure
    }
    
    public func save(from  data: Data, for url: URL, completionHandler:@escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { result in
            completionHandler(.failure(SaveError.failure))
        }
    }
}
