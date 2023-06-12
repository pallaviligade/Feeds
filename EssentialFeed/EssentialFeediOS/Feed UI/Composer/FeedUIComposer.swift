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
        
        refershViewController.onRefresh = addapatFeedToCellController(forwordingTo: feedViewController, loader: imageLoader)
        return feedViewController
    }
    
    private static func addapatFeedToCellController(forwordingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void  {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: loader)
            }
        }
    }
    
}
