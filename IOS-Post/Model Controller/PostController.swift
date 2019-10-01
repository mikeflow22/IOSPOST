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
    
    func fetchPosts(reset: Bool = true, completion: @escaping () -> Void){

        /*
         You  want  to order the posts in reverse chronological order. Determine the neccessary timestamp for your query based on whether you are resetting the list (where you want to use  the current time) or appending the list (where you would want to use the time of the earlier fetched post).
         1. Request the posts ordered by timestamp to put them in chronological order { orderBy }
         2. Specify that you want the list to end at the timestamp of the least recent Post you have already fetched (or at the current date if you haven't posted any)
         3. Specify that you want the posts at the end of that ordered list (endAt).
         4. Specify that you want the last 15 posts (limitToLast).
         
         */
        let  queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timestamp ?? Date().timeIntervalSince1970
        
        //build a [String: String] Dictionary literal of the URL Parameters you want to use.
        let urlParameters = ["orderBy": "\"timestamp\"", "endAt": "\(queryEndInterval)", "limitToLast": "15"]
        
        //Create a constant called queryItems. We need to compactMap over the urlParameters, turning them into URLQueryItems
        let queryItems =  urlParameters.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) //Potential error
        urlComponents?.queryItems = queryItems
        
        //create a url constant. Assign it the value returned form urlComponents.url
        guard let url = urlComponents?.url else { return }
        
//        let getterEndPoint = baseURL.appendingPathExtension("json")
        let getterEndPoint = url.appendingPathExtension("json")
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
                if reset {
                    self.posts = sortedArray
                } else {
                    self.posts.append(contentsOf: sortedArray)
                }
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
