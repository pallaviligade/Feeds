//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 30.04.23.
//

import Foundation
import XCTest
import EssentialFeed

private class URLSessionHTTpClientSpy {
    
    private  let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL,  completionHandler: @escaping (HTTPClientResult)  -> Void)  {
        session.dataTask(with: url) { _, _ ,  error in
            
            if let error = error {
                completionHandler(.failour(error))
                
            }

        }.resume()
    }
    
}

final class URLSessionHTTPClientTest : XCTestCase {
   
   
    
    func test_getFromUrl_FailsOnRequestError() {
       URLProtoclStub.startInterceptingRequest()
        let url = URL(string: "http://some-urls.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtoclStub.stub(url: url, error: error)
        
        let sut = URLSessionHTTpClientSpy()
        
        let exp = expectation(description: "wait for result to  load")
        
        sut.get(from: url) { result in
            switch result {
            case let .failour(recvied as NSError):
                XCTAssertEqual(recvied, error)
            default:
                XCTFail("Expected Error \(error), instead of got result \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtoclStub.stopInterceptingRequest()
    }
    
    // MARK: - helpers
    private class URLProtoclStub: URLProtocol {
        
       private static var stubs = [URL: stubList]()
        
       private struct stubList {
            let error: Error?
        }
        
       static func stub(url:URL, error: Error? = nil) {
        
            stubs[url] = stubList(error: error)
        }
        static func stopInterceptingRequest()  {
            URLProtoclStub.unregisterClass(URLProtoclStub.self)
            stubs = [:]
        }
        
        static func startInterceptingRequest() {
            URLProtoclStub.registerClass(URLProtoclStub.self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return URLProtoclStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtoclStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
       
        
    }
    
    
    
}
