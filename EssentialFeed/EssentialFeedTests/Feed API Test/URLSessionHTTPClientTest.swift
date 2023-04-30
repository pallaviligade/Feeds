//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 30.04.23.
//

import Foundation
import XCTest
import EssentialFeed

private class URLSessionHTTpClientSpy {
    
    private  let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL,  completionHandler: @escaping (HTTPClientResult)  -> Void)  {
        session.dataTask(with: url) { _, _ ,  error in
            
            if let error = error {
                completionHandler(.failour(error))
                
            }

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
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1) // Expections
    }
    
    func test_getFromUrl_FailsOnRequestError() {
        let url = URL(string: "http://some-urls.com")!
        let error = NSError(domain: "any error", code: 1)
        let session = URLSessionSpy() // Setup
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTpClientSpy(session: session)
        
        let exp = expectation(description: "wait for result to  load")
        sut.get(from: url) { result in
            switch result {
            case let .failour(recvied as NSError):
                XCTAssertEqual(recvied, error)
            default:
                XCTFail("Expected Error \(error), instead of got result \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
    }
    
    // MARK: - helpers
    private class URLSessionSpy: URLSession {
        
       private var stubs = [URL: stubList]()
        
       private struct stubList {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        func stub(url:URL,  task:  URLSessionDataTask = FakeSessionData(), error: Error? = nil) {
        
            stubs[url] = stubList(task: task, error: error)
            
        }
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
        {
            guard let stub = stubs[url] else {
                fatalError("could not fnd \(url)")
            }
            completionHandler(nil ,nil , stub.error )
            return stub.task
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
