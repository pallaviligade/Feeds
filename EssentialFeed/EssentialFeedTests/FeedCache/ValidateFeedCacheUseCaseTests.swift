//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 10.05.23.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreations() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.recivedMessages, [])
        
        
    }
    
    func test_validateCache_deleteCacheOnRetrivals() {
        let (sut, store) = makeSUT()
        sut.validateCahe()
        
        store.completeRetrieval(with: anyError())
        XCTAssertEqual(store.recivedMessages, [.retrival,.deleteCachedFeed])
        
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCahe()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recivedMessages, [.retrival])
    }

    private func makeSUT(currentDate:@escaping() -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store:feedStoreSpy)
    {
        let store = feedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate:currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
}
