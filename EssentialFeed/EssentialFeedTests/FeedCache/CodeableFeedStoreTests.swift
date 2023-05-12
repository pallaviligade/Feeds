//
//  CodeableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 11.05.23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    
   private struct Cache: Codable {
        let item: [LocalFeedImage]
        let timespam: Date
    }
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    func retrival(complectionHandler:@escaping FeedStore.RetrievalCompletion) {
        guard let data  =  try? Data(contentsOf: storeURL) else { return complectionHandler(.empty) }
        let decorder = JSONDecoder()
        let json = try! decorder.decode(Cache.self, from: data)
        complectionHandler(.found(feed: json.item, timestamp: json.timespam))
    }
    func insertItem(_ item: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        
       let encoder = JSONEncoder()
       let encode = try! encoder.encode(Cache(item: item, timespam: timestamp))
     //  guard let storeURL = storeURL else { return }
       try! encode.write(to: storeURL)
        completion(nil)
        
    }
    
}

final class CodeableFeedStoreTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
      try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
         let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
       try? FileManager.default.removeItem(at: storeURL)
    }
    
    
    
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
    
    func test_retrive_hasNosideEffectsOnemptyCacheTwice()
    {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait till expectation")
        
       
        sut.retrival { firstResult in
            sut.retrival { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                    
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        
        let sut = CodableFeedStore()
        let feed = uniqueItems()
        let timespam =  Date()
        
        let exp = expectation(description: "wait till expectation")
       
        sut.insertItem(feed.localitems, timestamp: timespam) { insertionError in
            XCTAssertNil(insertionError, "item  insertion fails got this error")
            
            sut.retrival { result in
                switch result {
                case let .found(feed: retivalFeed, timestamp: retivalsTimespam):
                    XCTAssertEqual(retivalFeed, feed.localitems)
                    XCTAssertEqual(retivalsTimespam, timespam)
                default:
                 XCTFail("expected found result  with \(feed) & timesapma\(timespam) and got result \(result)")
                }
                exp.fulfill()
            }
            
        }
        wait(for: [exp], timeout: 1.0)
        
        
    }
    
}
