//
//  FeedPresenterTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 12.07.23.
//

import XCTest
import EssentialFeed

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewmodel: FeedViewModel)
}

struct FeedLoadingViewModel{
    let isLoading:  Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

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

final class FeedPresenter {
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    private let feedview: FeedView
    
    init(feedview: FeedView,errorView: FeedErrorView, loadingview: FeedLoadingView) {
        self.errorView = errorView
        self.loadingView = loadingview
        self.feedview = feedview
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(_ feed: [FeedImage])  {
        feedview.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
     
}

class FeedPresenterTest: XCTestCase{
    
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
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: viewSpy) {
        let view = viewSpy()
        //Action initalizer
        let sut = FeedPresenter(feedview: view, errorView: view, loadingview: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
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


