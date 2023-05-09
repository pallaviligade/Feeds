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
                
        exptact(sut, tocompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
      
        
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let ( sut,store) = makeSUT()
        
        
        exptact(sut, tocompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
        
        func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
                let feed = uniqueImageFeed()
                let fixedCurrentDate = Date()
                let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
                let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

            exptact(sut, tocompleteWith: .success(feed.models), when: {
                store.completeRetrival(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
                })
            }

    
    private func makeSUT(currentDate:@escaping() -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store:feedStoreSpy) {
        let store = feedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate:currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
// MARK: - helpers:
    
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
            let models = [uniqueImage(), uniqueImage()]
            let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
            return (models, local)
        }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
        }
    
    private  func anyError()  -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    private func anyURL() -> URL {
            return URL(string: "http://any-url.com")!
        }
    
    private func exptact(_ sut: LocalFeedLoader,tocompleteWith expectedResult: LocalFeedLoader.loadResult, when action: ()-> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "wait until do")
        
        sut.load { recivedResult in
            switch (recivedResult, expectedResult) {
            case let (.success(recivedImages), .success(expectedImages)):
                XCTAssertEqual(recivedImages, expectedImages,file: file,line: line)
            case let (.failure(recivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(recivedError, expectedError,file: file,line: line)
            default:
                XCTFail("got result instead \(recivedResult)")
            }
            exp.fulfill()
        } // When
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
