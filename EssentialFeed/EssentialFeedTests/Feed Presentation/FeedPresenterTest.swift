//
//  FeedPresenterTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 12.07.23.
//

import XCTest

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

final  class FeedPresenter {
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    
    init(errorView: FeedErrorView, loadingview: FeedLoadingView) {
        self.errorView = errorView
        self.loadingView = loadingview
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
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
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: viewSpy) {
        let view = viewSpy()
        //Action initalizer
        let sut = FeedPresenter(errorView: view, loadingview: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class viewSpy: FeedErrorView, FeedLoadingView {
        
       //message enum captured recvied vlaues for view
        enum Message:  Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
       private(set) var message = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            message.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            message.insert(.display(isLoading: viewModel.isLoading))
        }
        
    }
    
}


