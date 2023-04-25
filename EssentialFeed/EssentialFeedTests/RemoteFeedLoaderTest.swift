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
      
        var captureError: RemoteFeedLoader.Error?
        client.error = NSError(domain: "Test", code: 0)
        sut.load(completion: { error in
            captureError = error } )
        
        XCTAssertEqual(captureError,.connectivity)
        
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
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            self.requestUrls.append(url)
//            completionHander.append(error as! RemoteFeedLoader.Error)
        }
        
    }

}
