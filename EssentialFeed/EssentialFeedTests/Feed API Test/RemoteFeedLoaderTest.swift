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
        
        sut.load { _ in  }
        
        XCTAssertEqual(client.requestUrls, [url])
        
    }
    
    func test_loadTwice_RequestsDataTwiceFromUrl() {
        let url = URL(string: "https://a-given-uel.com")!
        
        let (sut,client)  = makeSUT(url: url)
        
        sut.load { _ in  }
        sut.load { _ in  }
        
        XCTAssertEqual(client.requestUrls,[url, url])
        
    }
    
    func test_deliery_ErrorOnClientError() {
        let (sut,  client) = makeSUT()
        
        expact(sut, toCompleteWithResult: failure(.connectivity)) {
            let error =  NSError(domain: "Test", code: 0) // This is client error
            client.complete(with:error)
        }
    }
    func test_deliery_ErrorOn200HttpResponseError() {
        let (sut,  client) = makeSUT()
        [199,400, 101, 300].enumerated().forEach { index,statusCode in
            expact(sut, toCompleteWithResult: failure(.invaildData)) {
                let jsondata = makeItemsJSON([])
                client.complete(withstatusCode: statusCode, data: jsondata, at: index)
            }
        }
    }
    
    func test_delivery200Response_WithInvalidJson() {
        let (sut,  client) = makeSUT()
        
        expact(sut, toCompleteWithResult: failure(.invaildData)) {
            let invalidJson = Data(bytes:"invalid json".utf8)
            client.complete(withstatusCode: 200, data:invalidJson)
        }
    }
    
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut,  client) = makeSUT()
        
        expact(sut, toCompleteWithResult: .success([])) {
            let emptyJson = Data(bytes: "{\"items\": []}".utf8)
            client.complete(withstatusCode: 200,data: emptyJson)
        }
    }
    
    func test_loaditemAfter_Recvied200Response()
    {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)
        
        
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
        
        
        
        let itemsJSON = ["items":
        [item1.json, item2.json]]
        
        let item = [item1.model, item2.model]
        
        
        expact(sut, toCompleteWithResult: .success(item), when: {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withstatusCode: 200,data: json)
        })
        
    }
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
            let url = URL(string: "http://any-url.com")!
            let client = HTTPClientSpy()
            var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

            var capturedResults = [RemoteFeedLoader.Result]()
            sut?.load { capturedResults.append($0) }

            sut = nil
            client.complete(withstatusCode: 200, data: makeItemsJSON([]))

            XCTAssertTrue(capturedResults.isEmpty)
        }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
            let json = ["items": items]
            return try! JSONSerialization.data(withJSONObject: json)
        }
    
    
    private func makeItem(id:  UUID, description: String? = nil, location: String? = nil,imageURL: URL ) -> (model: FeedImage, json: [String:Any])
    {
        let item = FeedImage(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String:Any]()) { (acc, e) in
            if let value = e.value   { acc[e.key] = value }
        }
        return (item, json)
        
    }
    
    private func expact(_ sut:RemoteFeedLoader, toCompleteWithResult  expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
       // var captureError = [RemoteFeedLoader.Result]()
        
//        sut.load { error in
//            captureError.append(error)
//        }
        // below is pattern matching exmaple
        
        let exp = expectation(description: "wait for load completion")
        
        sut.load { recvivedResult in
            switch (recvivedResult, expectedResult) {
                
            case let (.success(recvivedItem),  .success(expectItems)):
                XCTAssertEqual(recvivedItem, expectItems, file: file,line: line)
                
            case let (.failure(recvivedError), .failure(expectedError)):
                XCTAssertEqual(recvivedError as! RemoteFeedLoader.Error, expectedError as! RemoteFeedLoader.Error, file: file,line: line)
                
            default:
                XCTFail("Expected \(expectedResult) and got \(recvivedResult) instead",file: file,line: line)
                
            }
            exp.fulfill()
            
        }
        action()
       
        wait(for: [exp], timeout: 1.0)
    }
    
    
    // MARK: - Helper
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    private func makeSUT(url: URL = URL(string: "https://some-uel.com")!, file: StaticString = #file, line: UInt = #line ) -> (sut:RemoteFeedLoader, client:HTTPClientSpy)
    {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
       trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
   
    private class HTTPClientSpy: Httpclient {
        
        private var messages = [(urls: URL, complection: (HTTPClientResult) -> Void)]()
        
        var requestUrls :[URL] {
            return messages.map { $0.urls }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error:Error,at index:Int = 0) {
            messages[index].complection(.failure(error))
        }
        
        func complete(withstatusCode code:Int,data:Data,at index:Int = 0) {
            let response = HTTPURLResponse(url: requestUrls[index],
                                           statusCode: code,
                                           httpVersion: nil, headerFields: nil)!
            messages[index].complection(.success(data, response))
            
        }
    }
    
}
