//
//  MainQueueDispatchDecorater.swift
//  EssentialFeediOS
//
//  Created by Pallavi on 04.07.23.
//

import Foundation
import EssentialFeed

 final class MainQueueDispatchDecorater<T> {
    
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion:@escaping () -> Void) {
        if Thread.isMainThread {
            completion()
        }
        else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
extension MainQueueDispatchDecorater: FeedLoader where T == FeedLoader {
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

extension MainQueueDispatchDecorater: FeedImageDataLoader where T == FeedImageDataLoader
{
    func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
      return  decoratee.loadImageData(from: url) {  [weak self] result in
            self?.dispatch { completionHandler(result) }
        }
    }

}
