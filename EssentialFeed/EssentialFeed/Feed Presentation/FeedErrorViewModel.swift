//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Pallavi on 14.07.23.
//

import Foundation

public struct FeedErrorViewModel {
  public let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) ->  FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
