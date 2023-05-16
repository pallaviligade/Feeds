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
        refreshControl?.beginRefreshing()
        loader?.load{ [weak self] result in
           guard let self = self else { return }
            self.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader(){
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
   
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
    
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3,"Expected yet another loading request once user initiates another reload")
        
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingloadingIndicator, "Expected loading indicator once view is loaded")
        
      
        loader.completeFeedloading(at: 0)
        XCTAssertFalse(sut.isShowingloadingIndicator,"Expected no loading indicator once loading is completed")
   
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingloadingIndicator,"Expected loading indicator once user initiates a reload")
        
        loader.completeFeedloading(at: 1)
         XCTAssertFalse(sut.isShowingloadingIndicator, "Expected no loading indicator once user initiated loading is completed")
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
       
        
        private var completionHander = [(FeedLoader.Result) -> Void] ()
        var loadCallCount: Int {
            return completionHander.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completionHander.append(completion)
        }
        
        func completeFeedloading(at index:Int) {
            completionHander[index](.success([]))
        }
         
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
            refreshControl?.simulatePullToRefresh()
        }
    
    var isShowingloadingIndicator:Bool {
        return refreshControl?.isRefreshing == true
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
      allTargets.forEach { target in
                    actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                        (target as NSObject).perform(Selector($0))
                    }
                }
    }
}
