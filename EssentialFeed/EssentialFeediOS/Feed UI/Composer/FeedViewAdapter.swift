//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 04.07.23.
//

import Foundation
import UIKit


final class  FeedViewAdapter: feedView {
   
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





