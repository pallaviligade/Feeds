//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 07.06.23.
//

import Foundation
import UIKit
import EssentialFeed

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: FeedImageView {
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell.locationContainer.isHidden = !model.hasLocation
                cell.locationLabel.text = model.location
                cell.discrptionLabel.text = model.description
                cell.feedImageView.image = model.image
                cell.feedImageContainer.isShimmering = model.isLoading
                cell.feedImageRetryButton.isHidden = !model.shouldRetry
                cell.onRetry = delegate.didRequestImage
    }
    
    typealias Image = UIImage
    
    
    
    
    private let delegate: FeedImageCellControllerDelegate
    private lazy var cell = FeedImageCell()
  
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    public  func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }
   
    public func preload() {
        delegate.didRequestImage()
    }
    
    public func cancelLoad() {
        delegate.didCancelImageRequest()
    }
    
   
}


/*public final class FeedImageCellController {
    
    private let viewModel: FeedImageCellViewModel<UIImage>
  
    init(ViewModel: FeedImageCellViewModel<UIImage>) {
        viewModel = ViewModel
    }
    
    public  func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }
   
    public func preload() {
        viewModel.loadImageData()
    }
    
    public func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.discrptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak  cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.OnImageLoadingStateChange = { [weak cell] isLoading  in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryStateloadImageChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
}
*/
