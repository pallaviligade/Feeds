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
        let item: [CodebaleFeedImage]
        let timespam: Date
       
       var localFeed: [LocalFeedImage] {
           return item.map {$0.local }
       }
       
    }
    
    private struct CodebaleFeedImage: Codable {
        private  let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image:LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }

    private let storeURL: URL
     
     init (_ store:  URL) {
         self.storeURL = store
     }
    
   // private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    func retrival(complectionHandler:@escaping FeedStore.RetrievalCompletion) {
        guard let data  =  try? Data(contentsOf: storeURL) else { return complectionHandler(.empty) }
        let decorder = JSONDecoder()
        let json = try! decorder.decode(Cache.self, from: data)
        complectionHandler(.found(feed: json.localFeed, timestamp: json.timespam))
    }
    func insertItem(_ item: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        
       let encoder = JSONEncoder()
        let caches = Cache(item: item.map(CodebaleFeedImage.init), timespam: timestamp)
       let encode = try! encoder.encode(caches)
     //  guard let storeURL = storeURL else { return }
       try! encode.write(to: storeURL)
        completion(nil)
        
    }
    
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
        let sut = makeSUT()
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
        
        let sut = makeSUT()
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
        
    }
    
    private func makeSUT( file: StaticString = #file, line: UInt = #line) -> CodableFeedStore  {
        let sut = CodableFeedStore(stupTestURL())
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
    private func deleteStoreArtifcate() {
        try? FileManager.default.removeItem(at: stupTestURL())
    }
    
    private func stupTestURL() -> URL  {
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
        return storeURL
    }
    
}
