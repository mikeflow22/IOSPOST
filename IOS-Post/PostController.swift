//
//  PostController.swift
//  IOS-Post
//
//  Created by Michael Flowers on 9/30/19.
//  Copyright © 2019 Michael Flowers. All rights reserved.
//

import Foundation

class PostController {
    
    static private let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts.json")!
    static var posts = [Post]()
    
    static private func fetchPosts(completion: @escaping () -> Void){
        let getterEndPoint = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: getterEndPoint) { (data, _, error) in
            if let error = error {
                print("Error in the data task: \(error), // \(error.localizedDescription), // \(#function)")
            }
            guard let data = data else { return }
            let jD = JSONDecoder()
            do {
                let postsDictionary = try  jD.decode([String : Post].self, from: data)
                let postArraysFromDictionary = postsDictionary.compactMap { $0.value }
                let sortedArray = postArraysFromDictionary.sorted(by: {$0.timestamp > $1.timestamp})
                self.posts = sortedArray
                completion()
            } catch {
                print("Error decoding post: \(error)")
                return
            }
        }.resume()
    }
    
}
