//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 04.08.23.
//

import XCTest
import EssentialFeed

final class CacheFeedImageDataUseCaseTests: XCTestCase {
    
    func test_init_doesNoCreateStoreUponCreations() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.recivedMessage.isEmpty)
    }
    
    func test_saveImageDataForURL_requetsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(from: data, for: url) { _ in  }
        XCTAssertEqual(store.recivedMessage, [.insert(data: data, url: url)])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:LocalFeedImageDataLoader, store:FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
        
    }
}
