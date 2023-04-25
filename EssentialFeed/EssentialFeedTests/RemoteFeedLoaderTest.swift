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
        
        sut.load ()
        
        XCTAssertEqual(client.requestUrls, [url])
        
    }
    
    func test_loadTwice_RequestsDataTwiceFromUrl() {
        let url = URL(string: "https://a-given-uel.com")!
       
        let (sut,client)  = makeSUT(url: url)
        
        sut.load ()
        sut.load ()
        
        XCTAssertEqual(client.requestUrls,[url, url])
        
    }
    
    func test_deliery_ErrorOnClientError() {
        let (sut,  client) = makeSUT()
      
        var captureError = [RemoteFeedLoader.Error]()
      
        sut.load(completion: { error in
            captureError.append(error) })
        let error =  NSError(domain: "Test", code: 0)
        client.complete(with:error)
        
        XCTAssertEqual(captureError,[.connectivity])
        
    }
    
    // MARK: - Helper
    private func makeSUT(url: URL = URL(string: "https://some-uel.com")!) -> (sut:RemoteFeedLoader, client:HTTPClientSpy)
    {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: Httpclient {
      var requestUrls = [URL]()
        var completionHander = [RemoteFeedLoader.Error] ()
        var error:Error?
        var complection = [(Error) -> Void]()
         
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            complection.append(completion)
            self.requestUrls.append(url)

        }
        
        func complete(with error:Error,at index:Int = 0) {
            complection[0](error)
        }
        
    }

}
