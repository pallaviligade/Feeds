//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Pallavi on 14.07.23.
//

import Foundation

public struct FeedViewModel {
    public let feed: [FeedImage]
}

public protocol FeedView {
    func display(_ viewmodel: FeedViewModel)
}

public struct FeedLoadingViewModel{
    public let isLoading:  Bool
}

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public struct FeedErrorViewModel {
  public let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) ->  FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
   
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    private let feedview: FeedView
    private var feedLoadError: String {
            return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                tableName: "Feed",
                bundle: Bundle(for: FeedPresenter.self),
                comment: "Error message displayed when we can't load the image feed from the server")
        }
    public static var title: String {
            return NSLocalizedString("FEED_VIEW_TITLE",
                tableName: "Feed",
                bundle: Bundle(for: FeedPresenter.self),
                comment: "Title for the feed view")
        }
    
    public  init(feedview: FeedView,errorView: FeedErrorView, loadingview: FeedLoadingView) {
        self.errorView = errorView
        self.loadingView = loadingview
        self.feedview = feedview
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(_ feed: [FeedImage])  {
        feedview.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
     
}
