//
//  CodeableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 11.05.23.
//

import XCTest
import EssentialFeed

protocol FeedStoreSpec {
    func test_retrive_deliveryEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
   // func test_retrive_hasNosideEffectsOnemptyCacheTwice()
   // func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues()
   
   
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overidesPreviouslyInsertedCache()
   

    func test_delete_HasNoSideEffectOnEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()
    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    
    func test_storeSideEffect_RunSerily()
}
protocol FailableRetrivalFeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}
protocol FailableInsertFeedStoreSpecs {
    func test_insert_deliveryErrorOnInsertionError()
    func test_insert_hasNoSideEffectInInsertionError()
}

protocol DeleteFeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}
final class CodeableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        deleteStoreArtifcate()
    }
    
    override func tearDown() {
        super.tearDown()
        deleteStoreArtifcate()
    }
    
    
    
    func test_retrive_deliveryEmptyCache() {
        let sut = makeSUT()
        
        expact(sut, toRetive: .empty)
    }
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
            let sut = makeSUT()

            expect(sut, toRetrieveTwice: .empty)
        }
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
            let sut = makeSUT()
        let feed = uniqueItems().localitems
            let timestamp = Date()

            insert((feed, timestamp), to: sut)

        expact(sut, toRetive: .found(feed: feed, timestamp: timestamp))
        }
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
            let sut = makeSUT()
            let feed =  uniqueItems().localitems
            let timestamp = Date()

            insert((feed, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
        }
  /*
    func test_retrive_hasNosideEffectsOnemptyCacheTwice()
    {
        let sut = makeSUT()
     //   let exp = expectation(description: "wait till expectation")
        expact(sut, toRetive: .empty)
        expact(sut, toRetive: .empty)

//        sut.retrival { firstResult in
//            sut.retrival { secondResult in
//                switch (firstResult, secondResult) {
//                case (.empty, .empty):
//                    break
//                default:
//                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
//
//                }
//                exp.fulfill()
//            }
//        }
//        wait(for: [exp], timeout: 1.0)
    }
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        
        let sut = makeSUT()
        let feed = uniqueItems()
        let timespam =  Date()
        
        let exp = expectation(description: "wait till expectation")
       
        sut.insertItem(feed.localitems, timestamp: timespam) { insertionError in
            XCTAssertNil(insertionError, "item  insertion fails got this error")
            exp.fulfill()
            
        }
        wait(for: [exp], timeout: 1.0)
        
        expact(sut, toRetive: .found(feed: feed.localitems, timestamp: timespam))
        
        
    }
    
    func test_retrivals_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueItems()
        let timespam =  Date()
        
        let exp = expectation(description: "wait till expectation")
       
        sut.insertItem(feed.localitems, timestamp: timespam) { insertionError in
            XCTAssertNil(insertionError, "item  insertion fails got this error")
            
            sut.retrival { firstReslt in
                sut.retrival { secondResult in
                    switch (firstReslt,secondResult) {
                    case let (.found(firstFound), .found(secondFound)):
                        XCTAssertEqual(firstFound.feed, feed.localitems)
                        XCTAssertEqual(firstFound.timestamp, timespam)
                        
                        XCTAssertEqual(secondFound.feed, feed.localitems)
                        XCTAssertEqual(secondFound.timestamp, timespam)
                    default:
                     XCTFail("expected retriveing twice from non empty cache to deliver same found result with feed\(feed) & timesapma\(timespam) and got firstresult \(firstReslt) and secondResult\(secondResult)")
                    }
                    exp.fulfill()
                }
                
            }
            
        }
        wait(for: [exp], timeout: 1.0)
        
    }*/
    
    func test_retrieve_deliversFailureOnRetrievalError() {
       
        let storeURL = testSpecificStoreURL() // Given store URL
        let sut = makeSUT(storeURL: storeURL) //  with SUT
        do{
            try "invaild data".write(to: storeURL, atomically: false, encoding: .utf8) // When
            expact(sut, toRetive: .failure(anyError())) // We expact it will failour
        }catch {
            XCTFail("while writing error occured")
        }
    }
    func test_retrieve_hasNoSideEffectsOnFailure()  {
        let storeURL = testSpecificStoreURL()
                let sut = makeSUT(storeURL: storeURL)

                try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

                expect(sut, toRetrieveTwice: .failure(anyError()))
    }
    func test_insert_deliversNoErrorOnEmptyCache() {
            let sut = makeSUT()

            let insertionError = insert((uniqueItems().localitems, Date()), to: sut)

            XCTAssertNil(insertionError, "Expected to insert cache successfully")
        }

        func test_insert_deliversNoErrorOnNonEmptyCache() {
            let sut = makeSUT()
            insert((uniqueItems().localitems, Date()), to: sut)

            let insertionError = insert((uniqueItems().localitems, Date()), to: sut)

            XCTAssertNil(insertionError, "Expected to override cache successfully")
        }
    func test_insert_overidesPreviouslyInsertedCache()
    {
        /*let sut = makeSUT()
        insert((uniqueItems().localitems,Date()), to: sut)

        let latestFeed = uniqueItems().localitems
        let latestTimestamp = Date()
        insert((latestFeed, latestTimestamp), to: sut)

        expact(sut, toRetive: .found(feed: latestFeed, timestamp: latestTimestamp))*/
        
        let sut = makeSUT()

                let firstInsertionError = insert((uniqueItems().localitems, Date()), to: sut)
                XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")

                let latestFeed = uniqueItems().localitems
                let latestTimestamp = Date()
                let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)

                XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        expact(sut, toRetive: .found(feed: latestFeed, timestamp: latestTimestamp)
               
    }
   
    

    func test_insert_deliveryErrorOnInsertionError() {
        let invalidaURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidaURL)
        let feed = uniqueItems().localitems
        let timestamp = Date()
        
        let secondError  = insert((feed,timestamp), to: sut)
        
        XCTAssertNotNil(secondError,"expected cache insertions fails with error")
        
        
    }
    
    func test_insert_hasNoSideEffectInInsertionError() {
        let invalidaURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidaURL)
        let feed = uniqueItems().localitems
        let timestamp = Date()
        
        insert((feed,timestamp), to: sut)
        
        expact(sut, toRetive: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut   =  makeSUT()
        
       let  deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        
    }
    func test_delete_hasNoSideEffectsOnEmptyCache() {
            let sut = makeSUT()

            deleteCache(from: sut)

        expact(sut, toRetive: .empty)
        }
    func test_delete_deliversNoErrorOnNonEmptyCache() {
            let sut = makeSUT()
            insert((uniqueItems().localitems, Date()), to: sut)

      let deletionError  = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
      }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
            let sut = makeSUT()
            insert((uniqueItems().localitems, Date()), to: sut)

            deleteCache(from: sut)

        expact(sut, toRetive: .empty)
        }
    func test_delete_deliversErrorOnDeletionError() {
            let noDeletePermissionURL = cachesDirectory()
            let sut = makeSUT(storeURL: noDeletePermissionURL)

            let deletionError = deleteCache(from: sut)

            XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
        }
    func test_delete_hasNoSideEffectsOnDeletionError() {
            let noDeletePermissionURL = cachesDirectory()
            let sut = makeSUT(storeURL: noDeletePermissionURL)

            deleteCache(from: sut)

        expact(sut, toRetive: .empty)
        }

   func test_storeSideEffect_RunSerily() {
        let sut = makeSUT()
        
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insertItem(uniqueItems().localitems, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.retrival { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(completedOperationsInOrder,[op1,op2,op3], "Expected side-effects to run serially but operations finished in the wrong order")
        
        
    }
    

       
    @discardableResult
    private func deleteCache(from sut: FeedStore) -> Error? {
        
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
    private func insert(_ cache:(feed: [LocalFeedImage], timespam: Date), to sut:FeedStore) ->  Error?
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
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrivalsCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expact(sut, toRetive: expectedResult, file: file, line: line)
        expact(sut, toRetive: expectedResult, file: file, line: line)
        }
    
    private func expact(_ sut:FeedStore, toRetive expectedResult:RetrivalsCachedFeedResult ,file: StaticString = #file, line: UInt = #line) {
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
    
    private func makeSUT(storeURL: URL? = nil,  file: StaticString = #file, line: UInt = #line) -> FeedStore  {
        let sut = CodableFeedStore(storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
    private func deleteStoreArtifcate() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
   
    private func testSpecificStoreURL() -> URL {
            return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
        }
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
