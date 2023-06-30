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
        let presentionAdapter = feedLoaderPresentionAdapter(loader: feedloader)
        
        let feedViewController = FeedViewController.makeWith(delegate: presentionAdapter, title: FeedPresenter
            .title)
        presentionAdapter.presenter = FeedPresenter(
            loadingView: WeakRefVirtualProxy(feedViewController),
            feedView: FeedViewAdapter(controller: feedViewController, loader: imageLoader))
      
      
        return feedViewController
    }
    
    
}

private extension FeedViewController {
    
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
      
        feedViewController.delegate = delegate
        feedViewController.title = FeedPresenter.title
        return feedViewController
        
        
    }
}
private final class WeakRefVirtualProxy <T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedloadingView  where T: FeedloadingView {
    func display(_ viewModel: FeedloadingViewModel) {
        object?.display(viewModel)
    }
    
    
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}

private final class  FeedViewAdapter: feedView {
   
   
    private weak var controller : FeedViewController?
    private let imageloader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.imageloader = loader
    }
    
    
    func displayFeed(_ viewModel: feedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
          //  FeedImageCellController(ViewModel: FeedImageCellViewModel(model:model , imageLoader: loader, imageTransfer: UIImage.init) )
            
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageloader)
                        let view = FeedImageCellController(delegate: adapter)

                        adapter.presenter = FeedImagePresenter(
                            view: WeakRefVirtualProxy(view),
                            imageTransformer: UIImage.init)

                        return view
        }
    }

}


private final class feedLoaderPresentionAdapter: FeedViewControllerDelegate  {
   
    
    
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
                self?.presenter?.didFinishLoadingFeed(error)
                break
            }
          
        }
        
    }
    
}

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    var presenter: FeedImagePresenter<View, Image>?

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartImageLoadingData(for: model)

        let model = self.model
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)

            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }

    func didCancelImageRequest() {
        task?.cancel()
    }
}
