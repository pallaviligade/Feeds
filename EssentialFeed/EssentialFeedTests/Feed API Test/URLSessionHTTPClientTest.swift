//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 30.04.23.
//

import Foundation
import XCTest

private class URLSessionHTTpClientSpy {
    
    private  let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _ ,  _ in

        }
    }
    
}

final class URLSessionHTTPClientTest : XCTestCase {
    
    func test_getFromURl_createsDataTaskWithURL(){
        let url = URL(string: "http://some-urls.com")!
        let session = URLSessionSpy() // Setup
        let sut = URLSessionHTTpClientSpy(session: session)
        sut.get(from: url)
        
        XCTAssertEqual(session.recviedUrls,[url] ) // Expections
    }
    private class URLSessionSpy: URLSession {
        
        var recviedUrls = [URL]()
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            recviedUrls.append(url)
            return FakeSessionData()
        }
        
    }
    
    private class FakeSessionData: URLSessionDataTask {
        
    }
    
}
