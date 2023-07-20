//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 19.07.23.
//

import XCTest


class RemoteFeedImageDataLoader {
    init(url: URL) {
        
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_initDoesNotRequiresAnyUrl() {
        let (client, _) = makeSUT()
        
        XCTAssertTrue(client.requestUrl.isEmpty)
    }
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line)  -> (client: HTTPClientSpy, sut: RemoteFeedImageDataLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(url: url)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (client, sut)
    }
    
    
    private class HTTPClientSpy {
        var requestUrl = [URL]()
    }

}
