//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 12.06.23.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    private  let feedloader:  FeedLoader
    
    init(feedload: FeedLoader) {
        self.feedloader = feedload
    }
    
  
    var onChange: ((FeedViewModel) ->Void)?
    var onFeedLoad: (([FeedImage])-> Void)?
    
    var isLoading: Bool = false {
        didSet { onChange?(self) } // When it change send on change notification to view
    }
    
   
    func loadFeed()
    {
       isLoading = true
        feedloader.load{ [weak self] result in
            guard let self = self else { return }
            
            if let feed  = try? result.get()  {
                self.onFeedLoad?(feed)
            }
            isLoading = false
        }
    }
    
}
