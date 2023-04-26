//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 21.04.23.
//

import XCTest
import EssentialFeed


final class RemoteFeedLoaderTest: XCTestCase {

    func test_doesNotRequestDataFromUrl() {
       
        let (_,client)  = makeSUT()
        XCTAssertTrue(client.requestUrls.isEmpty)
        
    }

    func test_load_RequestsDataFromUrl() {
        let url = URL(string: "https://a-given-uel.com")!
       
        let (sut,client)  = makeSUT(url: url)
        
        sut.load { _ in  }
        
        XCTAssertEqual(client.requestUrls, [url])
        
    }
    
    func test_loadTwice_RequestsDataTwiceFromUrl() {
        let url = URL(string: "https://a-given-uel.com")!
       
        let (sut,client)  = makeSUT(url: url)
        
        sut.load { _ in  }
        sut.load { _ in  }
        
        XCTAssertEqual(client.requestUrls,[url, url])
        
    }
    
    func test_deliery_ErrorOnClientError() {
        let (sut,  client) = makeSUT()
      
        expact(sut, toCompleteWithError: .connectivity) {
            let error =  NSError(domain: "Test", code: 0) // This is client error
            client.complete(with:error)
        }
      
       
        
    }
    func test_deliery_ErrorOn200HttpResponseError() {
        let (sut,  client) = makeSUT()
        
        
            [400, 101, 300].enumerated().forEach { index,statusCode in
            expact(sut, toCompleteWithError: .invaildData) {
              client.complete(with: statusCode, at:index)
            }
        }
       
    
    }
    
    func test_delivery200Response_WithInvalidJson() {
        let (sut,  client) = makeSUT()
     
        expact(sut, toCompleteWithError: .invaildData) {
            let invalidJson = Data(bytes:"invalid json".utf8)
            client.complete(with: 200, data:invalidJson)
        }
        
        
        
    }
    
    private func expact(_ sut:RemoteFeedLoader, toCompleteWithError  error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var captureError = [RemoteFeedLoader.Error]()
        sut.load { error in
            captureError.append(error)
        }
        action()
        XCTAssertEqual(captureError, [error], file: file,line: line)
        
    }
    
    
    // MARK: - Helper
    private func makeSUT(url: URL = URL(string: "https://some-uel.com")!) -> (sut:RemoteFeedLoader, client:HTTPClientSpy)
    {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: Httpclient {
       
        private var messages = [(urls: URL, complection: (HTTPClientResult) -> Void)]()
      
        var requestUrls :[URL] {
            return messages.map { $0.urls }
        }
       
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error:Error,at index:Int = 0) {
            messages[index].complection(.failour(error))
        }
        
        func complete(with statusCode:Int,data:Data = Data(),at index:Int = 0) {
            let response = HTTPURLResponse(url: requestUrls[index],
                                           statusCode: statusCode,
                                           httpVersion: nil, headerFields: nil)!
            messages[index].complection(.success(response))
            
        }
    }

}
