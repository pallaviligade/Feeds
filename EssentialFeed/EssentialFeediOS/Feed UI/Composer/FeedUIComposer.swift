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
        let presenterAdapter = feedLoaderPresentionAdapter(loader: feedloader)
        let refershViewController = FeedRefershViewController(delegate: presenterAdapter)
        
//        let storyBorad = UIStoryboard(name: "Feed", bundle: Bundle(for: FeedViewController.self))
//        let feedViewController = storyBorad.instantiateInitialViewController() as! FeedViewController
        let feedViewController = FeedViewController(refershViewController: refershViewController)
        presenterAdapter.presenter = FeedPresenter(loadingView:  weakRefVirtulaProxy(refershViewController),
                                                   feedView: FeedViewAdapter(controller: feedViewController, loader: imageLoader))
      
      
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
    func display(_ viewModel: FeedloadingViewModel) {
        object?.display(viewModel)
    }
    
    
}

private final class  FeedViewAdapter: feedView {
   
   
    private weak var controller : FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    
    func displayFeed(_ viewModel: feedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            FeedImageCellController(ViewModel: FeedImageCellViewModel(model:model , imageLoader: loader, imageTransfer: UIImage.init) )
        }
    }

}


private final class feedLoaderPresentionAdapter: FeedRefershViewControllerDelegate  {
   
    
    
   var presenter: FeedPresenter?
    private let loader:  FeedLoader
    
    init( loader: FeedLoader) {
        self.loader = loader
    }
    
    func didRefershFeedRequest() {
        presenter?.didStartLoadingFeed()
        
        loader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(feed)
                break
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(error)
                break
            }
          
        }
        
    }
    
}
