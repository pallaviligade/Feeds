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
    
    func test_saveImageDataFromURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalFeedImageDataLoader.SaveError.failure)) {
            
            store.completeInsertion(with: anyError())
            
        }
        
    }
    
    func test_saveImageDataFromURL_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeInsertionSuccessfully()
        }
        
    }
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith ExpectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file:StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load completion")
        
        sut.save(from: anyData(), for: anyURL()) { RecivedResult in
            
            switch (RecivedResult, ExpectedResult) {
            case (.success(), .success()):
                break
            case  (.failure(let receivedError as LocalFeedImageDataLoader.SaveError),
                   .failure(let expectedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expectedError, file: file,line: line)
                break
            default:
                XCTFail("Expected result \(ExpectedResult), got \(RecivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
            
        }
        action()
        wait(for: [exp], timeout: 3.0)
        
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:LocalFeedImageDataLoader, store:FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
        
    }
}
