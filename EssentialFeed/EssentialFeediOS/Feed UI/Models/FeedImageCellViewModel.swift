//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 13.06.23.
//

import Foundation
import EssentialFeed

final class FeedImageCellViewModel<Image> {
   typealias Observer<T>  = (T) ->  Void
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransfer: (Data) -> Image?
    
    init( model: FeedImage, imageLoader: FeedImageDataLoader, imageTransfer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransfer = imageTransfer
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
    
    var onImageLoad: Observer <Image>?  //((UIImage) -> Void)?
    var OnImageLoadingStateChange: Observer<Bool>? //((Bool) ->  Void)?
    var onShouldRetryStateloadImageChange: ((Bool) ->Void)?
    
    func loadImageData() {
        OnImageLoadingStateChange?(true)
        onShouldRetryStateloadImageChange?(false)
        task = self.imageLoader.loadImageData(from: model.imageURL, completionHandler: { [weak self] result in
            self?.handle(result)
        })
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransfer) {
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
