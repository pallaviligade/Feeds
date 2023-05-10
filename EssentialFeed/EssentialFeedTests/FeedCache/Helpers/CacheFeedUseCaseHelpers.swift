//
//  CacheFeedUseCaseHelpers.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 10.05.23.
//

import Foundation
import EssentialFeed

func uiqureItem() -> FeedImage  {
    return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    
}

 func uniqueItems() -> (models: [FeedImage], localitems: [LocalFeedImage]) {
    
    let model = [uiqureItem(), uiqureItem()]
    let localitems = model.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
return (model, localitems)
    
    
}
 func anyURL() -> URL {
   return URL(string: "http://any-url.com")!
}
  func anyError()  -> NSError {
    return NSError(domain: "any error", code: 1)
}

 extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
