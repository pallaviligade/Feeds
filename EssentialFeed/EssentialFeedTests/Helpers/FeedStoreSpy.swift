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
     
     private var deletionCompletions = [(Error?) -> Void]()
     private var insertionCompletions = [(Error?) -> Void]()
    private var retrivalCompletions = [(Error?) -> Void]()
     
     private(set) var recivedMessages = [RecivedMessage]()
     
     
     func deleteCachedFeed(completion: @escaping (Error?) -> Void) {
         deletionCompletions.append(completion)
         recivedMessages.append(.deleteCachedFeed)
     }
     
     func completeDeletion(with error:Error, index: Int = 0)  {
         deletionCompletions[index](error)
     }
     func completeDeletionSuccessFully(at index: Int = 0) {
         deletionCompletions[index](nil)
     }
     
     func insertItem(_ item: [LocalFeedImage], timestamp: Date, completion: @escaping (Error?) -> Void ) {
         insertCallCount +=  1
         insertionCompletions.append(completion)
         recivedMessages.append(.insert(item, timestamp))
     }
     
     func completeInsertion(with error:Error, index: Int = 0)  {
         insertionCompletions[index](error)
     }
     func completeInsertionSuccessfully(at index:Int = 0) {
         insertionCompletions[index](nil)
     }
    
    func retrival(complectionHandler: @escaping RetrievalCompletion) {
        retrivalCompletions.append(complectionHandler)
        recivedMessages.append(.retrival)
    }
    
    func completeRetrieval(with error: Error, at index:Int = 0){
        retrivalCompletions[index](error)
    }
 }
