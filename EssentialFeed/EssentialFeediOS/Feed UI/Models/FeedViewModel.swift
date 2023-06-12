//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 12.06.23.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    
    typealias Observer<T> = (T) ->Void
    private  let feedloader:  FeedLoader
    
    init(feedload: FeedLoader) {
        self.feedloader = feedload
    }
    
  
    var onloadingStateChage: Observer<Bool>? // loading state change
    var onFeedLoad: Observer<[FeedImage]>? // Notifiy new version of feeds 
    
   
    
   
    func loadFeed()
    {
        onloadingStateChage?(true)
        feedloader.load{ [weak self] result in
            guard let self = self else { return }
            
            if let feed  = try? result.get()  {
                self.onFeedLoad?(feed)
            }
            onloadingStateChage?(false)
        }
    }
    
}
