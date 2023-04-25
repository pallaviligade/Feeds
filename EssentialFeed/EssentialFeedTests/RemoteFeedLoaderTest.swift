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
      
        var captureError = [RemoteFeedLoader.Error]()
      
        sut.load(completion: { error in
            captureError.append(error) })
        let error =  NSError(domain: "Test", code: 0) // This is client error
        client.complete(with:error)
        
        XCTAssertEqual(captureError,[.connectivity])
        
    }
    func test_deliery_ErrorOn200HttpResponseError() {
        let (sut,  client) = makeSUT()
      
        var captureError = [RemoteFeedLoader.Error]()
      
        sut.load(completion: { error in
            captureError.append(error) })
       
        client.complete(with: 400)
        
        XCTAssertEqual(captureError,[.invaildData])
        
    }
    
    // MARK: - Helper
    private func makeSUT(url: URL = URL(string: "https://some-uel.com")!) -> (sut:RemoteFeedLoader, client:HTTPClientSpy)
    {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: Httpclient {
        var completionHander = [RemoteFeedLoader.Error] ()
       

        private var messages = [(urls: URL, complection: (Error?, HTTPURLResponse?) -> Void)]()
         
        var requestUrls :[URL] {
            return messages.map { $0.urls }
        }
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error:Error,at index:Int = 0) {
            messages[index].complection(error, nil)
        }
        
        func complete(with statusCode:Int,at index:Int = 0) {
            let response = HTTPURLResponse(url: requestUrls[index],
                                           statusCode: statusCode,
                                           httpVersion: nil, headerFields: nil)
            messages[index].complection(nil, response)
            
        }
    }

}
