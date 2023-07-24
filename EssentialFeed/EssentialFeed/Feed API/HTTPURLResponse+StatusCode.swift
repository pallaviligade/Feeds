//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Pallavi on 24.07.23.
//

import Foundation

extension HTTPURLResponse {
    static var OK_200: Int { return 200 }
    
    var isOk: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
