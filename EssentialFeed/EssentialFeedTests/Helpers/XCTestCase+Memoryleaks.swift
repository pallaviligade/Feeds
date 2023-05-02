//
//  XCTestCase+Memoryleaks.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 02.05.23.
//

import XCTest

extension XCTestCase {

     func trackForMemoryLeaks(_ instance:AnyObject, file: StaticString = #file, line: UInt = #line ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
