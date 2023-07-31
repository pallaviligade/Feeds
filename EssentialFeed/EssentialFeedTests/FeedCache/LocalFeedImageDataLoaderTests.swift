//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 28.07.23.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrieve(dataForUrl url: URL)
}

final class LocalFeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void ) -> FeedImageDataLoaderTask {
        store.retrieve(dataForUrl: url)
        return Task()
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
        
        var recivedMessage = [message]()
        
        func retrieve(dataForUrl url: URL) {
            recivedMessage.append(.retrieve(dataForUrl: url))
        }
        
        
    }
    
}
