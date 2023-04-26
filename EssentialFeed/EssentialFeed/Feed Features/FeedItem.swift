//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Pallavi on 21/04/23.
//

import Foundation

public struct FeedItem:Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
