//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 28.07.23.
//

import XCTest
import EssentialFeed


class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_initdoesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.recivedMessage.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoreDataForUrl() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.recivedMessage, [.retrieve(dataForUrl: url)])
    }
    
    func test_loadImageFromData_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith:.failure(LocalFeedImageDataLoader.loadError.failed) , when: {
                    let retrievalError = anyNSError()
                    store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_loadImageFromData_deliversNotFoundErrorOnNotFound()  {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound()) {
            store.completeRetrieval(with: .none)
        }
    }
    func test_loadImageFromData_deliversStoredDataOnFoundData()  {
    let (sut, store) = makeSUT()
    let foundData = anyData()
        
        expect(sut, toCompleteWith: .success(foundData)) {
        
            store.completeRetrieval(with: foundData)
        }
        
    }
    
    func test_loadImageDataFromUrl_doesNotDeliverResultAfterCancelTask() {
        let (sut, store) = makeSUT()

                                var recivedResult = [FeedImageDataLoader.Result]()
                                let task = sut.loadImageData(from: anyURL()) { recivedResult.append($0) }
                                task.cancel()
                                
                                store.completeRetrieval(with: anyData())
                                store.completeRetrieval(with: .none)
                                store.completeRetrieval(with: anyError())
                                
                                XCTAssertTrue(recivedResult.isEmpty, "Expected No Result after canceling all  task")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = StoreSpy()
        
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        var recivedResult = [FeedImageDataLoader.Result]()
        
        _ = sut?.loadImageData(from: anyURL()) { recivedResult.append($0) }
        
        sut = nil
        store.completeRetrieval(with: anyData())
        
        XCTAssertTrue(recivedResult.isEmpty,"expected no  result after instance has been deallocated")
        
        
        
    }
    
    func test_saveImageDataForURL_requetsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(from: data, for: url) { _ in  }
        XCTAssertEqual(store.recivedMessage, [.insert(data: data, url: url)])
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.loadError.notFound)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith ExpectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: anyURL(), completionHandler: { recivedResult in
            
            switch (recivedResult, ExpectedResult) {
            case let (.success(recivedData), .success(expectedData)):
                XCTAssertEqual(recivedData, expectedData, file: file,line: line)
                
            case (.failure(let receivedError as LocalFeedImageDataLoader.loadError),
                  .failure(let expectedError as LocalFeedImageDataLoader.loadError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
            default:
                XCTFail("Expected result \(ExpectedResult), got \(recivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
            
        })
        action()
        wait(for: [exp], timeout: 3.0)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:LocalFeedImageDataLoader, store:StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
        
    }
    
    private class StoreSpy: FeedImageDataStore {
        
        
        enum message: Equatable {
            case retrieve(dataForUrl: URL)
            case insert(data: Data, url: URL)
        }
        
        private var Retrievalcompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
        
        var recivedMessage = [message]()
        
        func retrieve(dataForUrl url: URL, completionHandler: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            recivedMessage.append(.retrieve(dataForUrl: url))
            Retrievalcompletions.append(completionHandler)
        }
        
        func insert(_ data: Data, for url: URL, completionHandler: @escaping (InsertionResult) -> Void) {
            recivedMessage.append(.insert(data: data, url: url))
        }
        
        func completeRetrieval(with error: Error, index: Int = 0){
            Retrievalcompletions[index](.failure(error))
        }
        
        func completeRetrieval(with data: Data?, index: Int = 0){
            Retrievalcompletions[index](.success(data))
        }
        
    }
    
}
