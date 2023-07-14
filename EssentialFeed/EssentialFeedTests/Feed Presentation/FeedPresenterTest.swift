//
//  FeedPresenterTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 12.07.23.
//

import XCTest
import EssentialFeed




class FeedPresenterTest: XCTestCase{
    
    func test_isTitleLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
        
    }
    
    func test_init_doesNotSendMessagesToView() {
      let (_, view) = makeSUT()
      XCTAssertTrue(view.message.isEmpty,"Expected no view messages")
        
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessage_StartLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed() // Event
        
        XCTAssertEqual(view.message, [.display(errorMessage: .none),
                                      .display(isLoading: true)
                                     ])
    }
    
    func test_didFinishLoadingFeed_displayFeedandStopLoading() {
        let (sut, view) = makeSUT()
        let feedItem = uniqueItems().models
        
        sut.didFinishLoadingFeed()
        
        XCTAssertEqual(view.message,[.display(feed: feedItem),
                                     .display(isLoading: false)])
        
    }
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()
        sut.didFinishLoadingFeed(with: anyError())
        XCTAssertEqual(view.message, [.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
                                      .display(isLoading: false)
        ])
    }
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: viewSpy) {
        let view = viewSpy()
        //Action initalizer
        let sut = FeedPresenter(feedview: view, errorView: view, loadingview: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
            let table = "Feed"
            let bundle = Bundle(for: FeedPresenter.self)
            let value = bundle.localizedString(forKey: key, value: nil, table: table)
            if value == key {
                XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
            }
            return value
        }
    
    private class viewSpy: FeedView,FeedErrorView, FeedLoadingView {
        
       //message enum captured recvied vlaues for view
        enum Message:  Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
       private(set) var message = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            message.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            message.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewmodel: FeedViewModel) {
            message.insert(.display(feed: viewmodel.feed))
        }
        
    }
    
}


