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
        let presenter = FeedPresenter()
        let presenterAdapter = feedLoaderPresentionAdapter(presenter: presenter, loader: feedloader)
        let refershViewController = FeedRefershViewController(loadFeed: presenterAdapter.loadFeed)
        
    
        let feedViewController = storyBorad.instantiateInitialViewController() as! FeedViewController
        presenter.loadingView = weakRefVirtulaProxy(refershViewController)
        presenter.feedView = FeedViewAdapter(controller: feedViewController, loader: imageLoader)
      
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


private final class feedLoaderPresentionAdapter  {
    
    private let presenter: FeedPresenter
    private let loader:  FeedLoader
    
    init(presenter: FeedPresenter, loader: FeedLoader) {
        self.presenter = presenter
        self.loader = loader
    }
    
    func loadFeed() {
        presenter.didStartLoadingFeed()
        
        loader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter.didFinishLoadingFeed(feed)
                break
            case let .failure(error):
                self?.presenter.didFinishLoadingFeed(error)
                break
            }
          
        }
        
        
    }
    
}
