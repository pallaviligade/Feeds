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
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
       // let url = URL(string: "http://wrong-url.com")!
            session.dataTask(with: url) { _, _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    
                    completion(.failure(UnexpectedValuesRepresentation()))
                    
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
        
        let RequestError = NSError(domain: "any error", code: 1)

        let RecivedError = restltError(data: nil, response: nil, error: RequestError)
        
        
       
        XCTAssertNotNil(RecivedError)
            
        
    }
    
    func test_getFrpmUrl_failsOnAllnilValues(){
        let RecivedError = restltError(data: nil, response: nil, error: nil)
      XCTAssertNotNil(RecivedError)
        
    }
    
 
    
    // MARK: - helpers
    private func restltError(data:Data?, response:URLResponse?, error: Error?,file: StaticString = #file, line: UInt = #line) -> Error? {
        URLProtocolStub.startInterceptingRequests()
        URLProtocolStub.stub(data:data, response:response, error: error)
        
        let exp = expectation(description: "Wait for completion")
        let sut = makeSUT(file:file,line: line)
        var recivedError:Error?
        
        sut.get(from: anyURL()) { result in
            switch result {
             case let .failure(error):
                recivedError = error
              break
            default:
                XCTFail("Expected failure got \(result) instead",file: file,line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
        return recivedError
        
    }
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
