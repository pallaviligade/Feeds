//
//  FeedPresenterTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 12.07.23.
//

import XCTest

class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresenterTest: XCTestCase{
    
    func test_init_doesNotSendMessagesToView() {
      let (_, view) = makeSUT()
      XCTAssertTrue(view.message.isEmpty,"Expected no view messages")
        
    }
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: viewSpy) {
        let view = viewSpy()
        //Action initalizer
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    private class viewSpy {
        var message = [Any]()
    }
    
}


