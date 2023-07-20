//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 19.07.23.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    private let httpClient: Httpclient
    
    init(client: Httpclient) {
        httpClient = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (Any) -> Void){
        httpClient.get(from: url) { _ in }
    }
    
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_initDoesNotRequiresAnyUrl() {
        let (client, _) = makeSUT()
        
        XCTAssertTrue(client.requestUrl.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestDataFromURL() {
        let url = URL(string: "http://any-url.com")!
        let (client, sut) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestUrl, [url])
       
        
    }
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line)  -> (client: HTTPClientSpy, sut: RemoteFeedImageDataLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (client, sut)
    }
    
    
    private class HTTPClientSpy: Httpclient {
        var requestUrl = [URL]()
        
        func get(from url: URL, completion: @escaping (Httpclient.Result) -> Void) {
            requestUrl.append(url)
        }
    }

}
