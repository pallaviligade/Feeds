//
//  LoadFeedCacheFromCacheUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 09.05.23.
//

import XCTest
import EssentialFeed

final class LoadFeedCacheFromCacheUseCaseTest: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
       
        let ( _,store) = makeSUT()
        
        XCTAssertEqual(store.recivedMessages, [])
        
    }
    
    func test_loadRequestCacheRetrivals() {
        
        let ( sut,store) = makeSUT()
        
        sut.load { _ in } // When
        
        XCTAssertEqual(store.recivedMessages, [.retrival])
    }
    
    func test_loadFailsOnretrivalError() {
        
        let ( sut,store) = makeSUT()
        var retrivalError = anyError()
        
        let exp = expectation(description: "wait until do")
        var recviedError: Error?
        sut.load { error in
            recviedError = error
            exp.fulfill()
        } // When
        
        store.completeRetrival(error: retrivalError)
        wait(for: [exp], timeout: 3.0)
        
        XCTAssertEqual(recviedError as NSError?, retrivalError)
    }
    
    private func makeSUT(currentDate:@escaping() -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store:feedStoreSpy) {
        let store = feedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate:currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
// MARK: - helpers:
    
    private  func anyError()  -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}
