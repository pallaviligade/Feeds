//
//  FeedViewControllerTest+LocalizeTest.swift
//  EssentialFeediOSTests
//
//  Created by Pallavi on 30.06.23.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedViewControllerTests {
    
    func localizeKey(_ Key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let Bundle = Bundle(for: FeedPresenter.self)
        let value =  Bundle.localizedString(forKey: Key, value: nil, table: table)
        if value == Key {
            XCTFail("missing locations string for key \(Key) and \(value)", file: file, line: line)
        }
        return value
    }
    
}
