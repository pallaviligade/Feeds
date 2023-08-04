//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 04.08.23.
//

import Foundation
import EssentialFeed

 class FeedImageDataStoreSpy: FeedImageDataStore {
    
    
    enum message: Equatable {
        case retrieve(dataForUrl: URL)
        case insert(data: Data, url: URL)
    }
    
    private var Retrievalcompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    
    var recivedMessage = [message]()
    
    func retrieve(dataForUrl url: URL, completionHandler: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        recivedMessage.append(.retrieve(dataForUrl: url))
        Retrievalcompletions.append(completionHandler)
    }
    
    func insert(_ data: Data, for url: URL, completionHandler: @escaping (InsertionResult) -> Void) {
        recivedMessage.append(.insert(data: data, url: url))
    }
    
    func completeRetrieval(with error: Error, index: Int = 0){
        Retrievalcompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, index: Int = 0){
        Retrievalcompletions[index](.success(data))
    }
    
}
