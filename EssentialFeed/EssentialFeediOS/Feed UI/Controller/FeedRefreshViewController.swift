//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 07.06.23.
//

import Foundation
import EssentialFeed
import UIKit


final class FeedViewModel {
    private  let feedloader:  FeedLoader
    
    init(feedload: FeedLoader) {
        self.feedloader = feedload
    }
    private enum State {
        case pending
        case loading
        case loaded ([FeedImage])
        case failed
    }
    
    
    private var state: State = .pending {
        didSet { onChange?(self) }
    }
    var onChange: ((FeedViewModel) ->Void)?
    
    var isLoading: Bool {
        switch state {
        case .pending, .failed, .loaded:  return false
        case .loading:  return true
            
        }
    }
    
    var feed: [FeedImage]? {
        switch state {
        case let .loaded(feed): return feed
        case .failed, .loading, .pending: return nil
        }
    }
    
    func loadFeed()
    {
        state = .loading
        feedloader.load{ [weak self] result in
            guard let self = self else { return }
            
            if let feed  = try? result.get()  {
                state = .loaded(feed)
            }else {
                state = .failed
            }
        }
    }
    
}

final class FeedRefershViewController: NSObject {
    
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private  let feedViewModel:  FeedViewModel
    
    init(feedload: FeedLoader) {
        self.feedViewModel = FeedViewModel(feedload: feedload)
    }
    
    public var onRefresh: (([FeedImage])-> Void)?
    
    @objc func refresh()
    {
        feedViewModel.onChange =   { [weak self] viewModel in
            guard let self = self else { return }
            if viewModel.isLoading {
                view.beginRefreshing()
            }else {
                view.endRefreshing()
            }
            if let feed = viewModel.feed {
                self.onRefresh?(feed)
            }
        }
         // This binding logic between view model and view
        feedViewModel.loadFeed()
        
    }
    
   private func bind(_ view: UIRefreshControl) {
       
    }
}
