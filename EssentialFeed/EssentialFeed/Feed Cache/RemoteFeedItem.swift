//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Pallavi on 08.05.23.
//

import Foundation

internal struct RemoteFeedItem:Decodable {
    let id: UUID
     let description: String?
     let location: String?
      let image: URL
  
  
}
