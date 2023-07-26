
//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 30.04.23.
//

import Foundation
import XCTest
import EssentialFeed



final class URLSessionHTTPClientTest : XCTestCase {
    
   
    
  
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }
    
    func test_getFrom_UrlPerformsGetRequestWithURL() {
      
        let url = anyURL()
        let exp = expectation(description: "wait until excaption")
        
        URLProtocolStub.observeRequests {  request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
      
       makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 3.0)
                
    }
    func test_cancelGetFromURLTask_cancelsURLRequest() {
            let receivedError = restltError(taskHandler: { $0.cancel() }) as NSError?

            XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
        }
    
    func test_getFromUrl_FailsOnRequestError() {
        let requestError = anyError()
        let recivedError = restltError((data: nil, response: nil, error: requestError))
            
    
       
        XCTAssertNotNil(recivedError)
            
        
    }
    
    func test_getFrpmUrl_failsOnAllnilValues(){

        let nonHTTPResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
         let anyHTTPResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
       
        XCTAssertNotNil(restltError((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(restltError((data: nil, response: nonHTTPResponse, error: nil)))
        XCTAssertNotNil(restltError((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(restltError((data: anyData(), response: nonHTTPResponse, error: anyError())))
        XCTAssertNotNil(restltError((data: anyData(), response: anyHTTPResponse, error: anyError())))
        XCTAssertNotNil(restltError((data: anyData(), response: nonHTTPResponse, error: anyError())))
        XCTAssertNotNil(restltError((data: anyData(), response: anyHTTPResponse, error: anyError())))
        XCTAssertNotNil(restltError((data: anyData(), response: nonHTTPResponse, error: nil)))
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
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData(){
        let _  = anyData()
        let passedRespone =  HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
        URLProtocolStub.stub(data: nil, response:passedRespone , error: nil)
        
        let exp = expectation(description: "wait unti load")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .success(recivedData, recivedResponse):
                let emptyData  = Data()
                XCTAssertEqual(recivedData, emptyData)
                XCTAssertEqual(recivedResponse.url, passedRespone.url)
                XCTAssertEqual(recivedResponse.statusCode, passedRespone.statusCode)
                
            default:
                XCTFail("expect result, got  \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
    
//    func test_cancelGetFromURLTask_cancelsURLRequest() {
//            let url = anyURL()
//            let exp = expectation(description: "Wait for request")
//
//            let task = makeSUT().get(from: url) { result in
//                switch result {
//                case let .failure(error as NSError) where error.code == URLError.cancelled.rawValue:
//                    break
//
//                default:
//                    XCTFail("Expected cancelled result, got \(result) instead")
//                }
//                exp.fulfill()
//            }
//
//            task.cancel()
//            wait(for: [exp], timeout: 1.0)
//        }
//
    
 
    
    // MARK: - helpers
    private func restltError(_ values: (data:Data?, response:URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in}, file: StaticString = #file, line: UInt = #line) -> Error? {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
//        URLProtocolStub.startInterceptingRequests()
//        URLProtocolStub.stub(data:data, response:response, error: error)
        
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
      //  URLProtocolStub.removeStub()
        return recivedError
        
    }
    private func makeSUT(file: StaticString = #file, line: UInt = #line ) -> Httpclient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)

        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
  
    private func nonHTTPResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
   
   
    
    
    
}
