//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Pallavi on 16.05.23.
//

import UIKit
import XCTest

class FeedViewController: UIViewController
{
    private var loader: FeedViewControllerTests.FeedViewSpy?
    
    convenience init(loader: FeedViewControllerTests.FeedViewSpy ) {
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load()
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_loaderCount(){
        let loader = FeedViewSpy()
        let sut  = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = FeedViewSpy()
        let sut  = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    
     class FeedViewSpy{
         private(set) var loadCallCount: Int = 0
        
         func load() {
             loadCallCount += 1
         }
    }
}
