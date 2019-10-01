//
//  PostController.swift
//  IOS-Post
//
//  Created by Michael Flowers on 9/30/19.
//  Copyright © 2019 Michael Flowers. All rights reserved.
//

import Foundation

class PostController {
    
     private let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")!
     var posts = [Post]()
    
     func fetchPosts(completion: @escaping () -> Void){
        let getterEndPoint = baseURL.appendingPathExtension("json")
        print(getterEndPoint)
        
        URLSession.shared.dataTask(with: getterEndPoint) { (data, _, error) in
            if let error = error {
                print("Error in the data task: \(error), // \(error.localizedDescription), // \(#function)")
                completion()
                return
            }
            guard let data = data else {
                completion()
                return }
            
            let jD = JSONDecoder()
            
            do {
                let postsDictionary = try  jD.decode([String : Post].self, from: data) 
                let postArraysFromDictionary = postsDictionary.compactMap { $0.value }
                let sortedArray = postArraysFromDictionary.sorted(by: {$0.timestamp > $1.timestamp})
                self.posts = sortedArray
                completion()
            } catch {
                print("Error decoding post: \(error), //// \(error.localizedDescription)")
                return
            }
        }.resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping ()-> Void){
        let postToPost = Post(text: text, username: username)
        var postData: Data? //potential error here
        do {
            let jE = JSONEncoder()
            postData = try jE.encode(postToPost)
        } catch  {
            print("Error Encoding post to post: \(error) \(#function)")
        }
       let postEndpoint = baseURL.appendingPathExtension("json")
        var  urlRequest = URLRequest(url: postEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postData
        
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let responseStatus = response as? HTTPURLResponse {
                print("This is the response status: \(responseStatus.statusCode)")
            }
            if let error = error {
                print("Error in the data task: \(error), // \(error.localizedDescription), // \(#function)")
                completion()
                return
            }
            
            guard let data = data else {
                print("Error unwrapping data: \(#function)")
                return
            }
            let dataAsString = String(data: data, encoding: .utf8)
            if let testDataString = dataAsString {
                print("Success!!!! Data = \(testDataString)")
            } else {
                print("WE FAILED")
            }
            
            self.fetchPosts(completion: {
                completion()
            })
            
        }.resume()
        
    }
    
}
