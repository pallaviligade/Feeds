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
 
    private  let loadingView: FeedloadingView // loading state change
    private let feedView: feedView // Notifiy new version of feeds
    
    init(loadingView: FeedloadingView, feedView: feedView) {
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    static var title: String {
        return "My Feed"
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedloadingViewModel(isloading: true))
    }
    func didFinishLoadingFeed(_ feed: [FeedImage]) {
        self.feedView.displayFeed(feedViewModel(feed: feed))
        self.loadingView.display(FeedloadingViewModel(isloading: false))
    }
   
    func didFinishLoadingFeed(_ with: Error) {
        self.loadingView.display(FeedloadingViewModel(isloading: false))
    }
    
}

