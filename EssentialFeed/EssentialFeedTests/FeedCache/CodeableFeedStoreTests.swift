//
//  CodeableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 11.05.23.
//

import XCTest
import EssentialFeed


final class CodeableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {

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
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
        
    }
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
            let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
           // expect(sut, toRetrieveTwice: .empty)
        }
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
            let sut = makeSUT()
        let feed = uniqueItems().localitems
            let timestamp = Date()

            insert((feed, timestamp), to: sut)

        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
        }
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
            let sut = makeSUT()
            let feed =  uniqueItems().localitems
            let timestamp = Date()

            insert((feed, timestamp), to: sut)

        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
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
            expect(sut, toRetive: .failure(anyError())) // We expact it will failour
        }catch {
            XCTFail("while writing error occured")
        }
    }
    func test_retrieve_hasNoSideEffectsOnFailure()  {
        let storeURL = testSpecificStoreURL()
                let sut = makeSUT(storeURL: storeURL)

        do{
            try "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
            expect(sut, toRetrieveTwice: .failure(anyError()))
        }catch {
            XCTFail("while writing error occured")
        }
               
    }
    func test_insert_deliversNoErrorOnEmptyCache() {
            let sut = makeSUT()

//            let insertionError = insert((uniqueItems().localitems, Date()), to: sut)
//
//            XCTAssertNil(insertionError, "Expected to insert cache successfully")
        
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
        }

        func test_insert_deliversNoErrorOnNonEmptyCache() {
            let sut = makeSUT()
//            insert((uniqueItems().localitems, Date()), to: sut)
//
//            let insertionError = insert((uniqueItems().localitems, Date()), to: sut)
//
//            XCTAssertNil(insertionError, "Expected to override cache successfully")
            assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
        }
    func test_insert_overidesPreviouslyInsertedCache()
    {
       
        
        let sut = makeSUT()

//                let firstInsertionError = insert((uniqueItems().localitems, Date()), to: sut)
//                XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
//
//                let latestFeed = uniqueItems().localitems
//                let latestTimestamp = Date()
//                let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
//
//                XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
//        expact(sut, toRetive: .found(feed: latestFeed, timestamp: latestTimestamp))
        
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
               
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
        
        expect(sut, toRetive: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut   =  makeSUT()
        
//       let  deletionError = deleteCache(from: sut)
//
//        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
        
    }
    func test_delete_hasNoSideEffectsOnEmptyCache() {
            let sut = makeSUT()

//        let deletionError = deleteCache(from: sut)
//
//        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
//
//        expact(sut, toRetive: .empty)
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
        }
    func test_delete_deliversNoErrorOnNonEmptyCache() {
            let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
      }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
            let sut = makeSUT()
//            insert((uniqueItems().localitems, Date()), to: sut)
//
//            deleteCache(from: sut)
//
//        expect(sut, toRetive: .empty)
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
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
//
//            deleteCache(from: sut)
//
//        expact(sut, toRetive: .empty)
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
        }

   func test_storeSideEffect_RunSerily() {
        let sut = makeSUT()
        
       assertThatSideEffectsRunSerially(on: sut)
        
        
    }
    

    func makeSUT(storeURL: URL? = nil,  file: StaticString = #file, line: UInt = #line) -> FeedStore  {
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
