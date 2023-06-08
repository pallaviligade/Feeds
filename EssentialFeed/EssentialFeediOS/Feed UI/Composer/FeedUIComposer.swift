//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 08.06.23.
//

import Foundation
import EssentialFeed

public final class FeedUIComposer {
    
    private init() {}
    public  static func createFeedView(feedloader: FeedLoader, imageLoader:  FeedImageDataLoader) -> FeedViewController {
        
        let refershViewController = FeedRefershViewController(feedload: feedloader)
        
        let feedViewController = FeedViewController(refershViewController: refershViewController)
        
        refershViewController.onClick = { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        return feedViewController
    }
    
    private func addatFeedToCellController(forwordingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void  {
        
    }
    
}
