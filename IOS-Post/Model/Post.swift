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
    //You will notice that there is a repeated post where every new fetch occured. Our endAt  query parameter is inclusive, meaning that it will include any posts that  match the exact timestamp of the last post. So each time we run the fetchPosts function, the API will return a duplicate of the last post. Fix it by adjusting the timestamp we use for the query
    var queryTimestamp: TimeInterval {
        return self.timestamp + 0.00001
    }
    
    init(text: String, timestamp: TimeInterval = Date().timeIntervalSince1970, username: String){
        self.text = text
        self.timestamp = timestamp
        self.username = username
    }
}

//struct Toplevel: Codable {
//    let posts: [
//}
