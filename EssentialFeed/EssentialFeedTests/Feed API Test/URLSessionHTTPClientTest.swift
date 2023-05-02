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
       // let url = URL(string: "http://wrong-url.com")!
            session.dataTask(with: url) { _, _, error in
                if let error = error {
                    completion(.failure(error))
                }
            }.resume()
        }
    
}

final class URLSessionHTTPClientTest : XCTestCase {
    
   
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFrom_UrlPerformsGetRequestWithURL() {
      
        let url = anyURL()
        let exp = expectation(description: "wait until excaption")
        
        URLProtocolStub.oberserRequest {  request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
      
       makeSUT().get(from: url) { _ in
            
        }
        wait(for: [exp], timeout: 3.0)
        
        
        
    }
    
    func test_getFromUrl_FailsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data:nil, response:nil, error: error)
        
        
        let exp = expectation(description: "Wait for completion")
        
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.code, error.code)
                XCTAssertNotNil(receivedError)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_failsOnRequestError() {
//      let requestError = anyNSError()
//
//      let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))
//
//      XCTAssertNotNil(receivedError)
    }
    
    // MARK: - helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line ) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        let url = URL(string: "http://any-url.com")!
        return url
    }
   
    private class URLProtocolStub: URLProtocol {
        
        private static var stubs: Stub?
         private static var requestOberser: ((URLRequest) -> Void)?

        private struct Stub {
            let error: Error?
            let data: Data?
            let response: URLResponse?
        }
        
        static func oberserRequest(_ observer:@escaping (URLRequest) -> Void) {
            
            requestOberser = observer
            
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
            requestOberser = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
           
            
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestOberser?(request)
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
