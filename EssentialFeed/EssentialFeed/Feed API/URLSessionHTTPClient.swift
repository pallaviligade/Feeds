//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Pallavi on 02.05.23.
//

import Foundation

public final class URLSessionHTTPClient:Httpclient {
    
    public  let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session  
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
            let wrapped: URLSessionTask

            func cancel() {
                wrapped.cancel()
            }
        }
    
    public func get(from url: URL, completion: @escaping (Httpclient.Result) -> Void) -> HTTPClientTask {
        // let url = URL(string: "http://wrong-url.com")!
        
        
       let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }else if let data = data, let response = response as? HTTPURLResponse  {
                completion(.success((data, response)))
            }
            else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }
            task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
    
}
