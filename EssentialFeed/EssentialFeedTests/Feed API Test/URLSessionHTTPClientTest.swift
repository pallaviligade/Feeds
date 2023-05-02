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
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }else if let data = data,data.count > 0, let response = response as? HTTPURLResponse  {
                completion(.success(data, response))
            }
            else {
                
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
        let requestError = anyError()
        let recivedError = restltError(data: nil, response: nil, error: requestError)
       
        XCTAssertNotNil(recivedError)
            
        
    }
    
    func test_getFrpmUrl_failsOnAllnilValues(){

        let nonHTTPResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
         let anyHTTPResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
       
        XCTAssertNotNil(restltError(data: nil, response: nil, error: nil))
        XCTAssertNotNil(restltError(data: nil, response: nonHTTPResponse, error: nil))
        XCTAssertNotNil(restltError(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(restltError(data: anyData(), response: nonHTTPResponse, error: anyError()))
        XCTAssertNotNil(restltError(data: anyData(), response: anyHTTPResponse, error: anyError()))
        XCTAssertNotNil(restltError(data: anyData(), response: nonHTTPResponse, error: anyError()))
        XCTAssertNotNil(restltError(data: anyData(), response: anyHTTPResponse, error: anyError()))
        XCTAssertNotNil(restltError(data: anyData(), response: nonHTTPResponse, error: nil))
    }
    
    func test_getFromUrl_SuccessOnAllValidHTTPURLResponse(){
        let passedData  = anyData()
        let passedRespone =  HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
        URLProtocolStub.stub(data: anyData(), response:passedRespone , error: nil)
        
        let exp = expectation(description: "wait unti load")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(recivedData, recivedResponse):
                XCTAssertEqual(recivedData, passedData)
                XCTAssertEqual(recivedResponse.url, passedRespone.url)
                XCTAssertEqual(recivedResponse.statusCode, passedRespone.statusCode)
                
            default:
                XCTFail("expect result, got  \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
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
       return URL(string: "http://any-url.com")!
    }
    
    private  func anyError()  -> Error {
        return NSError(domain: "any error", code: 1)
    }
    
    private func anyData() ->  Data  {
        return  Data(bytes: "anystring".utf8)
    }
    private func nonHTTPResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
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
