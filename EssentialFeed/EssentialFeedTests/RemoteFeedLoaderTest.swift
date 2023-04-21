//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 21.04.23.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        Httpclient.shared.get(from: URL(string: "https://some-url.com")!)
    }
    
}
class Httpclient {
    
    static var shared = Httpclient()
    
    func get(from url: URL) {}
    
}

class HTTPClientSpy: Httpclient {
            var requstedUrl:URL?
          override  func get(from url: URL) {
              self.requstedUrl = url
          }
    
}

final class RemoteFeedLoaderTest: XCTestCase {

    func test_doesNotRequestDataFromUrl() {
        let client = HTTPClientSpy()
        Httpclient.shared = client
        _  = RemoteFeedLoader()
        XCTAssertNil(client.requstedUrl)
        
    }

    func test_loadRequestDataFromUrl() {
        
        let client = HTTPClientSpy()
        Httpclient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load ()
        XCTAssertNotNil(client.requstedUrl)
        
    }
}
