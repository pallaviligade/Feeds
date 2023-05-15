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
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            expect(sut, toRetive: .empty, file: file, line: line)
        }
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            expect(sut, toRetrieveTwice: .empty, file: file, line: line)
        }
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueItems().localitems
            let timestamp = Date()

            insert((feed, timestamp), to: sut)

            expect(sut, toRetive: .found(feed: feed, timestamp: timestamp), file: file, line: line)
        }
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let feed = uniqueItems().localitems
            let timestamp = Date()

            insert((feed, timestamp), to: sut)

            expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp), file: file, line: line)
        }
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let insertionError = insert((uniqueItems().localitems, Date()), to: sut)

            XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
        }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueItems().localitems, Date()), to: sut)

            let insertionError = insert((uniqueItems().localitems, Date()), to: sut)

            XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
        }
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueItems().localitems, Date()), to: sut)

            let latestFeed = uniqueItems().localitems
            let latestTimestamp = Date()
            insert((latestFeed, latestTimestamp), to: sut)

            expect(sut, toRetive: .found(feed: latestFeed, timestamp: latestTimestamp), file: file, line: line)
        }
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let deletionError = deleteCache(from: sut)

            XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
        }
    
  

        func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            deleteCache(from: sut)

            expect(sut, toRetive: .empty, file: file, line: line)
        }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueItems().localitems, Date()), to: sut)

            let deletionError = deleteCache(from: sut)

            XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
        }

        func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueItems().localitems, Date()), to: sut)

            deleteCache(from: sut)

            expect(sut, toRetive:  .empty, file: file, line: line)
        }
    func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            var completedOperationsInOrder = [XCTestExpectation]()

            let op1 = expectation(description: "Operation 1")
            sut.insertItem(uniqueItems().localitems, timestamp: Date()) { _ in
                completedOperationsInOrder.append(op1)
                op1.fulfill()
            }

            let op2 = expectation(description: "Operation 2")
            sut.deleteCachedFeed { _ in
                completedOperationsInOrder.append(op2)
                op2.fulfill()
            }

            let op3 = expectation(description: "Operation 3")
            sut.insertItem(uniqueItems().localitems, timestamp: Date()) { _ in
                completedOperationsInOrder.append(op3)
                op3.fulfill()
            }

            waitForExpectations(timeout: 5.0)

            XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
        }
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
         expect(sut, toRetive: expectedResult, file: file, line: line)
         expect(sut, toRetive: expectedResult, file: file, line: line)
        }
    
     func expect(_ sut:FeedStore, toRetive expectedResult:RetrivalsCachedFeedResult ,file: StaticString = #file, line: UInt = #line) {
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
