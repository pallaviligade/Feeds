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

        }.resume()
    }
    
}

final class URLSessionHTTPClientTest : XCTestCase {
   
    func test_getFromURl_resumeDataTaskFromUrl(){
        let url = URL(string: "http://some-urls.com")!
        
        let session = URLSessionSpy() // Setup
        let task = URLSessionDataSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTpClientSpy(session: session)
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1) // Expections
    }
    
    // MARK: - helpers
    private class URLSessionSpy: URLSession {
        
        var stubs = [URL: URLSessionDataTask]()
        
        func stub(url:URL,  task:  URLSessionDataTask) {
        stubs[url] = task
        }
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeSessionData()
        }
        
    }
    
    private class FakeSessionData: URLSessionDataTask {
        override func resume() {}
    }
    private class URLSessionDataSpy: URLSessionDataTask {
        var resumeCallCount = 0
        override func resume() {
            resumeCallCount += 1
        }
    }
    
}
