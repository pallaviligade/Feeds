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
        var retrievalError = anyError()
        
        let exp = expectation(description: "wait until do")
        var receivedError: Error?
        sut.load { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("expected failour got result \(result)")
            }
            exp.fulfill()
        } // When
        
        store.completeRetrieval(with: retrievalError)
        wait(for: [exp], timeout: 3.0)
        
        XCTAssertEqual(receivedError as NSError?, retrievalError)
        
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let ( sut,store) = makeSUT()
        
        let exp = expectation(description: "wait until do")
        var receivedImage: [FeedImage]?
        
        sut.load { result in
            switch result {
            case let .success(images):
                receivedImage = images
            default:
                XCTFail("expected sucess got result \(result)")
            }
            exp.fulfill()
        } // When
        
        store.completeRetrievalSuccessfully()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedImage, [])
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
