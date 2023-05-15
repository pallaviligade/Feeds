//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 09.05.23.
//

import Foundation
import EssentialFeed

class feedStoreSpy: FeedStore {
   
     
     enum RecivedMessage: Equatable {
          case deleteCachedFeed
          case insert([LocalFeedImage], Date)
          case retrival
     }
     
     var insertCallCount = 0
     
     private var deletionCompletions = [DeletionCompletion]()
     private var insertionCompletions = [InsertionCompletion]()
     private var retrivalCompletions = [RetrievalCompletion]()
     
     private(set) var recivedMessages = [RecivedMessage]()
     
     
     func deleteCachedFeed(completion: @escaping DeletionCompletion) {
         deletionCompletions.append(completion)
         recivedMessages.append(.deleteCachedFeed)
     }
     
     func completeDeletion(with error:Error, index: Int = 0)  {
         deletionCompletions[index](.failure(error))
        
     }
     func completeDeletionSuccessFully(at index: Int = 0) {
         deletionCompletions[index](.success(()))
     }
     
     func insertItem(_ item: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion ) {
         insertCallCount +=  1
         insertionCompletions.append(completion)
         recivedMessages.append(.insert(item, timestamp))
     }
     
     func completeInsertion(with error:Error, index: Int = 0)  {
         insertionCompletions[index](.failure(error))
     }
     func completeInsertionSuccessfully(at index:Int = 0) {
         insertionCompletions[index](.success(()))
     }
    
    func retrival(complectionHandler: @escaping RetrievalCompletion) {
        retrivalCompletions.append(complectionHandler)
        recivedMessages.append(.retrival)
    }
    
    func completeRetrieval(with error: Error, at index:Int = 0){
        retrivalCompletions[index](.failure(error))
    }
    
//    func completeRetrievalSuccessfully(at index: Int = 0) {
//        retrivalCompletions[index](.failure(error))
//    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrivalCompletions[index](.success(.empty))
    }
    
    func completeRetrival(with feed:[LocalFeedImage], timestamp: Date, at index: Int = 0)
    {
        retrivalCompletions[index](.success(.found(feed: feed, timestamp: timestamp)))
    }
   
    
 }
