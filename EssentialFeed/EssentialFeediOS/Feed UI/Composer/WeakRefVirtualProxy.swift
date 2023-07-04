//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 04.07.23.
//

import Foundation
import EssentialFeed
import UIKit

final class WeakRefVirtualProxy <T: AnyObject> {
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
