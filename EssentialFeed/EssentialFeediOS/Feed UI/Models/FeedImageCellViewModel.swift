//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 13.06.23.
//

import Foundation
import UIKit
import EssentialFeed

final class FeedImageCellViewModel {
   typealias Observer<T>  = (T) ->  Void
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init( model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    var description: String? {
       return model.description
    }
    
    var location: String? {
        return model.location
    }
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var onImageLoad: ((UIImage) -> Void)?
    var OnImageLoadingStateChange: ((Bool) ->  Void)?
    var onShouldRetryStateloadImageChange: ((Bool) ->Void)?
    
    func loadImageData() {
        OnImageLoadingStateChange?(true)
        onShouldRetryStateloadImageChange?(false)
        task = self.imageLoader.loadImageData(from: model.imageURL, completionHandler: { [weak self] result in
            self?.handle(result)
        })
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(UIImage.init) {
            onImageLoad?(image)
        }else {
        
           onShouldRetryStateloadImageChange?(true)
        }
        OnImageLoadingStateChange?(false)
    }
    
    public func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
