//
//  FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 19.07.23.
//

import Foundation

public protocol FeedImageDataLoaderTask  {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from  url: URL, completionHandler: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
