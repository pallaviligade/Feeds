//
//  CodeableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 11.05.23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrival(complectionHandler:@escaping FeedStore.RetrievalCompletion) {
        complectionHandler(.empty)
    }
    
}

final class CodeableFeedStoreTests: XCTestCase {

    func test_retrive_deliveryEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait till expectation")
        
        sut.retrival { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("got item \(result) insead of empty cache")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
      
    }
   
    
}
