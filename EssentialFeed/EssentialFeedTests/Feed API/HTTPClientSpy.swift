//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 24.07.23.
//

import Foundation
import EssentialFeed

class HTTPClientSpy: Httpclient {
    private var messages = [(url: URL, completion:(Httpclient.Result) -> Void)]()
    private(set) var cancelledURLs = [URL]()
    
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() {
            callback()
        }
    }
    
    var requestUrl : [URL] {
        messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (Httpclient.Result) -> Void) ->  HTTPClientTask  {
        messages.append((url, completion))
                return Task { [weak self] in
                    self?.cancelledURLs.append(url)
                }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withstatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestUrl[index],
                                       statusCode: code,
                                       httpVersion: nil,
                                       headerFields: nil)!
        messages[index].completion(.success((data, response)))
    }
}
