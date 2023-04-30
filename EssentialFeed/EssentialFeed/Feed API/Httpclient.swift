//
//  Httpclient.swift
//  EssentialFeed
//
//  Created by Pallavi on 28.04.23.
//

import Foundation
public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}
public protocol Httpclient {
    func get(from url: URL,completion:@escaping (HTTPClientResult) -> Void )
}
