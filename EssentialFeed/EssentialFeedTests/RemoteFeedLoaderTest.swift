//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 21.04.23.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        Httpclient.shared.requstedUrl = URL(string: "https://some-url.com")
    }
    
}
class Httpclient {
    
    static let shared = Httpclient()
    var requstedUrl:URL?
    private init(){}
    
}

final class RemoteFeedLoaderTest: XCTestCase {

    func test_doesNotRequestDataFromUrl() {
        let client = Httpclient.shared
        _  = RemoteFeedLoader()
        XCTAssertNil(client.requstedUrl)
        
    }

    func test_loadRequestDataFromUrl() {
        
        let client = Httpclient.shared
        let sut = RemoteFeedLoader()
        
        sut.load ()
        XCTAssertNotNil(client.requstedUrl)
        
    }
}
