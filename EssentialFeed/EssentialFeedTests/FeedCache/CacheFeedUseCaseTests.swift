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
        store.deleteCacheFeed()
    }
    
}

class feedStore {
    var deleteCacheFeedCallCount = 0
    
    func deleteCacheFeed() {
        deleteCacheFeedCallCount = 1
        
    }
}


final class CacheFeedUseCaseTests: XCTestCase {

    
  
    func test_init_doesNotDeleteCacheUponCreation() {
       
        let store = feedStore()
        let sut = localFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
        
    }
    
    func test_save_RequestCacheDeleetion() {
        let store = feedStore()
        let sut = localFeedLoader(store: store)
        
        let items = [uiqureItem(), uiqureItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
        
    }
    
    //MARK: - Helpers
    
    private func uiqureItem() -> FeedItem  {
        return FeedItem(id: UUID(), description: "name", location: "Pune", imageURL: anyURL())
        
    }
    private func anyURL() -> URL {
       return URL(string: "http://any-url.com")!
    }
    
    private 

}
