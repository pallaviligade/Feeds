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
    private let currentDate: () -> Date
    
    init(store: feedStore,currentDate:@escaping () -> Date ) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ item: [FeedItem], completion: @escaping (Error?) -> Void = { _  in }){
        store.deleteCachedFeed(completion: { [unowned  self] error in
           
            if error == nil {
                self.store.insertItem(item, timestamp: self.currentDate(), completion: completion)
                
            }else {
                completion(error)
            }
            
        })
    }
    
}

class feedStore {
    
    enum RecivedMessage: Equatable {
         case deleteCachedFeed
         case insert([FeedItem], Date)
    }
    
    var insertCallCount = 0
    
    private var deletionCompletions = [(Error?) -> Void]()
    private var insertionCompletions = [(Error?) -> Void]()
    
    private(set) var recivedMessages = [RecivedMessage]()
    
    
    func deleteCachedFeed(completion: @escaping (Error?) -> Void) {
        deletionCompletions.append(completion)
        recivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error:Error, index: Int = 0)  {
        deletionCompletions[index](error)
    }
    func completeDeletionSuccessFully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insertItem(_ item: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void ) {
        insertCallCount +=  1
        insertionCompletions.append(completion)
        recivedMessages.append(.insert(item, timestamp))
    }
    
    func completeInsertion(with error:Error, index: Int = 0)  {
        insertionCompletions[index](error)
    }
    func completeInsertionSuccessfully(at index:Int = 0) {
        insertionCompletions[index](nil)
    }
}


final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
       
        let ( _,store) = makeSUT()
        
        XCTAssertEqual(store.recivedMessages, [])
        
    }
    
    func test_save_RequestCacheDeletion() {
       let (sut, store) = makeSUT()
        
        let items = [uiqureItem(), uiqureItem()]
        sut.save(items)
        
        XCTAssertEqual(store.recivedMessages, [.deleteCachedFeed])
        
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError () {
        let (sut, store) = makeSUT()
        let items = [uiqureItem(), uiqureItem()]
        let error = anyError()
        
        sut.save(items)
        store.completeDeletion(with: error)// when
        
        
        XCTAssertEqual(store.recivedMessages, [.deleteCachedFeed])

    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        
        let (sut, store) = makeSUT()
        let items = [uiqureItem(), uiqureItem()]
        
        sut.save(items)
        store.completeDeletionSuccessFully() // when
        
        XCTAssertEqual(store.insertCallCount, 1)

    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uiqureItem(), uiqureItem()]
        let (sut, store) =  makeSUT(currentDate: { timestamp })
      
        
        sut.save(items)
        store.completeDeletionSuccessFully() // when
        
        XCTAssertEqual(store.recivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])


    }
    
    func test_save_failsOnDeletionError () {
        let (sut, store) = makeSUT()
        let items = [uiqureItem(), uiqureItem()]
        let deletionError = anyError()
        
        let exp = expectation(description: "wait unti")
        var recviedError: Error?
        
        sut.save(items) { error  in
            recviedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)// when
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(recviedError as NSError?, deletionError)

    }
    
    func test_save_failsOnInsertionsError () {
        let (sut, store) = makeSUT()
        let items = [uiqureItem(), uiqureItem()]
        let insertionError = anyError()
        
        let exp = expectation(description: "wait unti")
        var recviedError: Error?
        
        sut.save(items) { error  in
            recviedError = error
            exp.fulfill()
        }
        store.completeDeletionSuccessFully()
        store.completeInsertion(with: insertionError)// when
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(recviedError as NSError?, insertionError)

    }
    
    func test_save_SuccessOnSuccesfullyCacheInsertions () {
        let (sut, store) = makeSUT()
        let items = [uiqureItem(), uiqureItem()]
        
        let exp = expectation(description: "wait unti")
        var recviedError: Error?
        
        sut.save(items) { error  in
            recviedError = error
            exp.fulfill()
        }
        store.completeDeletionSuccessFully()
        store.completeInsertionSuccessfully()// when
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNil(recviedError)

    }
    
    
    //MARK: - Helpers
    
    private func uiqureItem() -> FeedItem  {
        return FeedItem(id: UUID(), description: "name", location: "Pune", imageURL: anyURL())
        
    }
    private func anyURL() -> URL {
       return URL(string: "http://any-url.com")!
    }
    private  func anyError()  -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    private func makeSUT(currentDate:@escaping() -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: localFeedLoader, store:feedStore) {
        let store = feedStore()
        let sut = localFeedLoader(store: store, currentDate:currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }

}
