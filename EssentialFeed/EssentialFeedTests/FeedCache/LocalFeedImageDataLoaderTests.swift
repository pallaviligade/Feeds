//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 28.07.23.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForUrl url: URL, completionHandler: @escaping (Result) -> Void)
}

final class LocalFeedImageDataLoader {
    private final class Task: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
         func complete(with result: FeedImageDataLoader.Result) {
            self.completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
                    completion = nil
        }
        }
    private let store: FeedImageDataStore
    
    public enum Error: Swift.Error {
            case failed
            case notFound
    }
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void ) -> FeedImageDataLoaderTask {
        let task = Task(completion: completionHandler)
        
        store.retrieve(dataForUrl: url) { result in
           
            task.complete(with: result
                .mapError { _ in Error.failed}
                .flatMap { data in data.map{.success($0)} ?? .failure(Error.notFound) }
            )
        }
        return task
    }
}

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
        
        expect(sut, toCompleteWith:.failure(LocalFeedImageDataLoader.Error.failed) , when: {
                    let retrievalError = anyNSError()
                    store.complete(with: retrievalError)
        })
    }
    
    func test_loadImageFromData_deliversNotFoundErrorOnNotFound()  {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound()) {
            store.complete(with: .none)
        }
    }
    func test_loadImageFromData_deliversStoredDataOnFoundData()  {
    let (sut, store) = makeSUT()
    let foundData = anyData()
        
        expect(sut, toCompleteWith: .success(foundData)) {
        
            store.complete(with: foundData)
        }
        
    }
    
    func test_loadImageDataFromUrl_doesNotDeliverResultAfterCancelTask() {
        let (sut, store) = makeSUT()

        var recivedResult = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { recivedResult.append($0) }
        task.cancel()
        
        store.complete(with: anyData())
        store.complete(with: .none)
        store.complete(with: anyError())
        
        XCTAssertTrue(recivedResult.isEmpty, "Expected No Result after canceling all  task")
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.notFound)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith ExpectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: anyURL(), completionHandler: { recivedResult in
            
            switch (recivedResult, ExpectedResult) {
            case let (.success(recivedData), .success(expectedData)):
                XCTAssertEqual(recivedData, expectedData, file: file,line: line)
                
            case (.failure(let receivedError as LocalFeedImageDataLoader.Error),
                  .failure(let expectedError as LocalFeedImageDataLoader.Error)):
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
        }
        
        private var completions = [(FeedImageDataStore.Result) -> Void]()
        
        var recivedMessage = [message]()
        
        func retrieve(dataForUrl url: URL, completionHandler: @escaping (FeedImageDataStore.Result) -> Void) {
            recivedMessage.append(.retrieve(dataForUrl: url))
            completions.append(completionHandler)
        }
        
        func complete(with error: Error, index: Int = 0){
            completions[index](.failure(error))
        }
        
        func complete(with data: Data?, index: Int = 0){
            completions[index](.success(data))
        }
        
    }
    
}
