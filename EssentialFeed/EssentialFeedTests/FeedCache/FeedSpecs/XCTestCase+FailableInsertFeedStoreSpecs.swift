//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 15.05.23.
//

import Foundation
import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let insertionError = insert((uniqueItems().localitems, Date()), to: sut)

            XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
        }

        func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueItems().localitems, Date()), to: sut)

            expect(sut, toRetive:  .success(.empty), file: file, line: line)
        }
}
