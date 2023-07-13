//
//  FeedPresenterTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 12.07.23.
//

import XCTest

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) ->  FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final  class FeedPresenter {
    private let errorView: FeedErrorView
    
    init(errorView: FeedErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
    }
}

class FeedPresenterTest: XCTestCase{
    
    func test_init_doesNotSendMessagesToView() {
      let (_, view) = makeSUT()
      XCTAssertTrue(view.message.isEmpty,"Expected no view messages")
        
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed() // Event
        
        XCTAssertEqual(view.message, [.display(errorMessage: .none)])
    }
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: viewSpy) {
        let view = viewSpy()
        //Action initalizer
        let sut = FeedPresenter(errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class viewSpy: FeedErrorView {
       
       //message enum captured recvied vlaues for view
        enum Message:  Equatable {
            case display(errorMessage: String?)
        }
        
        var message = [Message]()
        
        func display(_ viewModel: FeedErrorViewModel) {
            message.append(.display(errorMessage: viewModel.message))
        }
        
    }
    
}


