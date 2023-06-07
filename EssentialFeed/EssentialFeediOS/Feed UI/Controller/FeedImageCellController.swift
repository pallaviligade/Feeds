//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 07.06.23.
//

import Foundation
import UIKit
import EssentialFeed

public final class FeedImageCellController {
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init( model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    
    public  func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (model.location) ==  nil
        cell.discrptionLabel.text = model.description
        cell.locationLabel.text = model.location
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
       
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            self.task = self.imageLoader.loadImageData(from: model.imageURL, completionHandler: { [weak cell] result in
                let imageData  = try? result.get()
                let image = imageData.map(UIImage.init)  ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
            })
            
        }
        
        cell.onRetry = loadImage
        loadImage()
        return cell
    }
    public func cancelLoad() {
        task?.cancel()
    }
    public func preload() {
        task = imageLoader.loadImageData(from: model.imageURL , completionHandler: { _ in })
    }
}
