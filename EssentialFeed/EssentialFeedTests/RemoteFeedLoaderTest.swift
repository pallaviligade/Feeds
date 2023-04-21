//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 21.04.23.
//

import XCTest

class RemoteFeedLoader
{
    let client: Httpclient
    let url: URL
    init(url: URL, client: Httpclient) {
        self.client = client
        self.url = url
    }
    func load() {
        self.client.get(from: url)
    }
    
}
protocol Httpclient {
    func get(from url: URL)
}


final class RemoteFeedLoaderTest: XCTestCase {

    func test_doesNotRequestDataFromUrl() {
       
        let (_,client)  = makeSUT()
        XCTAssertNil(client.requstedUrl)
        
    }

    func test_loadRequestDataFromUrl() {
        let url = URL(string: "https://a-given-uel.com")!
       
        let (sut,client)  = makeSUT(url: url)
        
        sut.load ()
        XCTAssertEqual(client.requstedUrl, url)
        
    }
    
    private func makeSUT(url: URL = URL(string: "https://some-uel.com")!) -> (sut:RemoteFeedLoader, client:HTTPClientSpy)
    {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
        
    }
    private class HTTPClientSpy: Httpclient {
        var requstedUrl:URL?
        func get(from url: URL) {
            self.requstedUrl = url
        }
        
    }

}
