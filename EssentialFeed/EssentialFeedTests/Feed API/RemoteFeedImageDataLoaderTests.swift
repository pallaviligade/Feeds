//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 19.07.23.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    public enum Error: Swift.Error {
        case invaildData
    }
    private let httpClient: Httpclient
    
    init(client: Httpclient) {
        httpClient = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        httpClient.get(from: url) { result in
            switch result {
            case .success:
                completion(.failure(Error.invaildData))
            case let .failure(error):
                completion(.failure(error))
            default: break
            }
        }
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
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = URL(string: "http://any-url.com")!
        let (client, sut) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestUrl, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (client, sut) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)
        
        expect(sut, tocompleteWith: .failure(clientError)) {
            client.complete(with: clientError)
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (client, sut) = makeSUT()
        let sample =  [404, 444, 302, 400, 500]
        
        sample.enumerated().forEach { index, code in
            expect(sut, tocompleteWith: failure(.invaildData)) {
                client.complete(with: code, data: anyData(), at: index)
            }
        }
        
    }
    //MARK: - Helpers
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader,tocompleteWith expectedResult:FeedImageDataLoader.Result, when action: () -> Void,
                        file: StaticString = #file, line: UInt = #line ) {
        let url = URL(string: "http://a-given-url.com")!
        let exp = expectation(description: "wait for expectation completed")
        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData,file:file, line:line)
            
            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            case let (.failure(recivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(recivedError, expectedError,file:file, line:line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
          
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line)  -> (client: HTTPClientSpy, sut: RemoteFeedImageDataLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (client, sut)
    }
    
    
    private class HTTPClientSpy: Httpclient {
        private var messages = [(url: URL, completion:(Httpclient.Result) -> Void)]()
        
        var requestUrl : [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (Httpclient.Result) -> Void) {
            messages.append((url,completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestUrl[index],
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }

}
