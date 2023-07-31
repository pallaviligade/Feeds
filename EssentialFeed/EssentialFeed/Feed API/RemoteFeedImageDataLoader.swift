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
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
            private var completion: ((FeedImageDataLoader.Result) -> Void)?

            var wrapped: HTTPClientTask?

            init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
                self.completion = completion
            }

            func complete(with result: FeedImageDataLoader.Result) {
                completion?(result)
            }

            func cancel() {
                preventFurtherCompletions()
                wrapped?.cancel()
            }

            private func preventFurtherCompletions() {
                completion = nil
            }
        }
    
   public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        
       let task = HTTPClientTaskWrapper(completion)
               task.wrapped = httpClient.get(from: url) { [weak self] result in
                   guard self != nil else { return }

                   task.complete(with: result
                       .mapError { _ in Error.connectivity }
                       .flatMap { (data, response) in
                           let isValidResponse = response.isOk  && !data.isEmpty
                           return isValidResponse ? .success(data) : .failure(Error.invaildData)
                       })
               }
               return task
           }
    
}

extension HTTPURLResponse {
    static var OK_200: Int { return 200 }
    
    var isOk: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
