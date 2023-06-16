//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 15.06.23.
//

import Foundation
import EssentialFeed

struct FeedloadingViewModel {
    let isloading: Bool
}
protocol FeedloadingView {
    func display(_ viewModel:  FeedloadingViewModel)
}
struct feedViewModel {
    let feed: [FeedImage]
}

protocol feedView {
    func displayFeed(_ viewModel:feedViewModel)
}


final class FeedPresenter {
    
    typealias Observer<T> = (T) ->Void
    private  let feedloader:  FeedLoader
    
    init(feedload: FeedLoader) {
        self.feedloader = feedload
    }
    
  
    var loadingView: FeedloadingView? // loading state change
    var feedView: feedView? // Notifiy new version of feeds
    
   
    
   
    func loadFeed()
    {
        loadingView?.display(FeedloadingViewModel(isloading: true))
        feedloader.load{ [weak self] result in
            guard let self = self else { return }
            
            if let feed  = try? result.get()  {
                self.feedView?.displayFeed(feedViewModel(feed: feed))
            }
            self.loadingView?.display(FeedloadingViewModel(isloading: false))
        }
    }
    
}

