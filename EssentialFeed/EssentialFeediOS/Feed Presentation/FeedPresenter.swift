//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 15.06.23.
//

import Foundation
import EssentialFeed
protocol FeedloadingView {
    func display(isloading:  Bool)
}

protocol feedView {
    func displayFeed(feedImages: [FeedImage])
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
        loadingView?.display(isloading: true)
        feedloader.load{ [weak self] result in
            guard let self = self else { return }
            
            if let feed  = try? result.get()  {
                self.feedView?.displayFeed(feedImages: feed)
            }
            self.loadingView?.display(isloading: false)
        }
    }
    
}

