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
    
    private let viewModel: FeedImageCellViewModel
  
    init(ViewModel: FeedImageCellViewModel) {
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
