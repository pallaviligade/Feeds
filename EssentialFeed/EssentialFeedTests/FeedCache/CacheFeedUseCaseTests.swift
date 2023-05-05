//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 04.05.23.
//

import XCTest
import EssentialFeed

class localFeedLoader {
    
    let store: feedStore
    
    init(store: feedStore) {
        self.store = store
    }
    
    func save(_ item: [FeedItem]){
        store.deleteCachedFeed(completion: { [unowned  self] error in
            
            if error == nil {
                self.store.insertItem(item)
                
            }
            
        })
    }
    
}

class feedStore {
    var deleteCacheFeedCallCount = 0
    var insertCallCount = 0
    
    private var deletionCompletions = [(Error?) -> Void]()
    
    func deleteCachedFeed(completion: @escaping (Error?) -> Void) {
        deleteCacheFeedCallCount = 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error:Error, index: Int = 0)  {
        deletionCompletions[index](error)
    }
    func completeDeletionSuccessFully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insertItem(_ item: [FeedItem]) {
        insertCallCount +=  1
    }
}


final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
       
        let ( _,store) = makeSUT()
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
        
    }
    
    func test_save_RequestCacheDeleetion() {
       let (sut, store) = makeSUT()
        
        let items = [uiqureItem(), uiqureItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
        
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError () {
        let (sut, store) = makeSUT()
        let items = [uiqureItem(), uiqureItem()]
        let error = anyError()
        
        sut.save(items)
        store.completeDeletion(with: error)// when
        
        
        XCTAssertEqual(store.insertCallCount, 0)

    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        
        let (sut, store) = makeSUT()
        let items = [uiqureItem(), uiqureItem()]
        
        sut.save(items)
        store.completeDeletionSuccessFully() // when
        
        XCTAssertEqual(store.insertCallCount, 1)

    }
    
    //MARK: - Helpers
    
    private func uiqureItem() -> FeedItem  {
        return FeedItem(id: UUID(), description: "name", location: "Pune", imageURL: anyURL())
        
    }
    private func anyURL() -> URL {
       return URL(string: "http://any-url.com")!
    }
    private  func anyError()  -> Error {
        return NSError(domain: "any error", code: 1)
    }
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: localFeedLoader, store:feedStore) {
        let store = feedStore()
        let sut = localFeedLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }

}
