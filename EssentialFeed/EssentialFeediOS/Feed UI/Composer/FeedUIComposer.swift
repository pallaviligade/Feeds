//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 08.06.23.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    
    private init() {}
    
    public  static func createFeedView(feedloader: FeedLoader, imageLoader:  FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedload: feedloader)
        let presenter = FeedPresenter(feedload: feedloader)
        let refershViewController = FeedRefershViewController(presenter: presenter)
        
        let storyBorad = UIStoryboard(name: "Feed", bundle: Bundle(for: FeedViewController.self))
    
        let feedViewController = storyBorad.instantiateInitialViewController() as! FeedViewController
        presenter.loadingView = weakRefVirtulaProxy(refershViewController)
        presenter.feedView = FeedViewAdapter(controller: feedViewController, loader: imageLoader)
        feedViewController.refershViewController = refershViewController
        
        
        feedViewModel.onFeedLoad = addapatFeedToCellController(forwordingTo: feedViewController, loader: imageLoader)
        return feedViewController
    }
    
    private static func addapatFeedToCellController(forwordingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void  {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(ViewModel: FeedImageCellViewModel(model:model , imageLoader: loader, imageTransfer: UIImage.init) )
            }
        }
    }
    
}
private final class weakRefVirtulaProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension weakRefVirtulaProxy: FeedloadingView  where T: FeedloadingView {
    func display(isloading: Bool) {
        object?.display(isloading: isloading)
    }
    
    
}

private final class  FeedViewAdapter: feedView {
   
    private weak var controller : FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    
    func displayFeed(feedImages: [EssentialFeed.FeedImage]) {
        controller?.tableModel = feedImages.map { model in
            FeedImageCellController(ViewModel: FeedImageCellViewModel(model:model , imageLoader: loader, imageTransfer: UIImage.init) )
        }
    }

}
