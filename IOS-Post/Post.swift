//
//  Post.swift
//  IOS-Post
//
//  Created by Michael Flowers on 9/30/19.
//  Copyright © 2019 Michael Flowers. All rights reserved.
//

import Foundation
struct Post: Codable {
    let text: String
    let timestamp: TimeInterval
    let username: String
    
    init(text: String, timestamp: TimeInterval = Date().timeIntervalSince1970, username: String){
        self.text = text
        self.timestamp = timestamp
        self.username = username
    }
}
