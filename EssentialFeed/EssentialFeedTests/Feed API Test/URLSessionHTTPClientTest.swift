//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 30.04.23.
//

import Foundation
import XCTest
import EssentialFeed

private class URLSessionHTTPClient {
    
    private  let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            session.dataTask(with: url) { _, _, error in
               // let url = URL(string: "http://wrong-url.com")
                if let error = error {
                    completion(.failure(error))
                }
            }.resume()
        }
    
}

final class URLSessionHTTPClientTest : XCTestCase {
    
    
    
    func test_getFromUrl_FailsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data:nil, response:nil, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    
    // MARK: - helpers
    private class URLProtocolStub: URLProtocol {
        
        private static var stubs: Stub?
        
        private struct Stub {
            let error: Error?
            let data: Data?
            let response: URLResponse?
        }
        
        static func stub(data:Data?, response:URLResponse? ,error: Error? ) {
            stubs = Stub(error: error, data: data, response: response)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
           
            
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
          
            
            if let data = URLProtocolStub.stubs?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stubs?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStub.stubs?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
        
        
    }
    
    
    
}
