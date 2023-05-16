//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Pallavi on 16.05.23.
//

import Foundation
import XCTest

class FeedViewController
{
    init(loader: FeedViewControllerTests.FeedViewSpy) {
        
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_loaderCount(){
        let loader = FeedViewSpy()
        let sut  = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loderCount, 0)
    }
    
     class FeedViewSpy{
         private(set) var loderCount: Int = 0
        
    }
}
