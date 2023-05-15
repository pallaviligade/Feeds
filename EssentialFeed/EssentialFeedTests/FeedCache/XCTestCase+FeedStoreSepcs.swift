//
//  XCTestCase+FeedStoreSepcs.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 15.05.23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpec where Self: XCTestCase
{
    @discardableResult
     func deleteCache(from sut: FeedStore) -> Error? {
        
        let exp = expectation(description: "wait till expections")
        var deletionError: Error?
        
        sut.deleteCachedFeed(completion: { recivedDeletionError in
            deletionError = recivedDeletionError
            exp.fulfill()
        })
        wait(for: [exp], timeout: 2.0)
        return deletionError
    }
    
    @discardableResult
     func insert(_ cache:(feed: [LocalFeedImage], timespam: Date), to sut:FeedStore) ->  Error?
    {
        let exp = expectation(description: "wait till expections")
        var insertionError: Error?
        
        sut.insertItem(cache.feed, timestamp: cache.timespam) { recivedInsertionError in
            insertionError = recivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
        
    }
    
     func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrivalsCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expact(sut, toRetive: expectedResult, file: file, line: line)
        expact(sut, toRetive: expectedResult, file: file, line: line)
        }
    
     func expact(_ sut:FeedStore, toRetive expectedResult:RetrivalsCachedFeedResult ,file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait till expectation")
           sut.retrival { retrievedResult in
                switch (retrievedResult, expectedResult) {
                case let (.found(expected), .found(retrive)):
                    XCTAssertEqual(expected.feed, retrive.feed, file: file, line:line)
                    XCTAssertEqual(expected.timestamp, retrive.timestamp, file:file, line:line)
                break
                case (.empty, .empty):
                    break
                case (.failure, .failure):
                    break
                
                default:
                 XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
                }
                exp.fulfill()
            }
            
        wait(for: [exp], timeout: 1.0)
    }
    
   
    
    
}
