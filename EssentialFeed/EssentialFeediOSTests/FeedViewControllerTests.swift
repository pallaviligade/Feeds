//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Pallavi on 16.05.23.
//

import UIKit
import XCTest
import EssentialFeed

class FeedViewController: UITableViewController
{
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
                refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
                load()
    }
    
   @objc func load()
    {
        loader?.load{ _ in }
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_loaderCount(){
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefersh_loadFresh(){
        
        let (sut, loader) = makeSUT()
        sut.refreshControl?.simulatePullRequest()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.refreshControl?.simulatePullRequest()
        XCTAssertEqual(loader.loadCallCount, 3)
        
        
    }
    func makeSUT(file: StaticString = #file, line: UInt = #line ) -> (sut:FeedViewController, loader: FeedViewSpy) {
        let loader = FeedViewSpy()
        let sut  = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    //MARK: - Helpers
    class FeedViewSpy: FeedLoader{
       
        
         private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
         
    }
}

extension UIRefreshControl {
    func simulatePullRequest() {
      allTargets.forEach { target in
                    actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                        (target as NSObject).perform(Selector($0))
                    }
                }
    }
}
