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
        let view = viewSpy()
        
        //Action initalizer
        let _ = FeedPresenter(view: view)
        XCTAssertTrue(view.message.isEmpty,"Expected no view messages")
        
    }
    //MARK: - Helpers
    private class viewSpy {
        var message = [Any]()
    }
    
}


