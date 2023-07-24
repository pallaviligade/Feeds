//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Pallavi on 19.07.23.
//

import Foundation

public final class RemoteFeedImageDataLoader {
    public enum Error: Swift.Error {
        case invaildData
        case connectivity
    }
    private let httpClient: Httpclient
    
   public init(client: Httpclient) {
        httpClient = client
    }
    
    private struct HTTPTaskWrapper: FeedImaegDataLoaderTask {
        
        let wrapped: HTTPClientTask
        
        func cancel() {
            wrapped.cancel()
        }
        
    }
    
   public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImaegDataLoaderTask {
        
        
      return HTTPTaskWrapper(wrapped: httpClient.get(from: url) { [weak self] result in
            guard self != nil else {
                return
            }
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    completion(.success(data))
                }else {
                    completion(.failure(Error.invaildData))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
    
}
