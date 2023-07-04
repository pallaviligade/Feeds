//
//  feedLoaderPresentionAdapter.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 04.07.23.
//

import Foundation
import EssentialFeed

final class feedLoaderPresentionAdapter: FeedViewControllerDelegate  {
   var presenter: FeedPresenter?
    private let feedloader:  FeedLoader
    
    init( loader: FeedLoader) {
        self.feedloader = loader
    }
    
    func didRefershFeedRequest() {
        presenter?.didStartLoadingFeed()
        
        feedloader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(feed)
                break
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
                break
            }
          
        }
        
    }
    
}
