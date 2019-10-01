//
//  PostListViewController.swift
//  IOS-Post
//
//  Created by Michael Flowers on 9/30/19.
//  Copyright © 2019 Michael Flowers. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController {
    
    var refreshControl = UIRefreshControl()
    
    private lazy var formmatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    var postController = PostController()
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.estimatedRowHeight = 45
        myTableView.rowHeight = UITableView.automaticDimension
        myTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        
        postController.fetchPosts {
            print("Called fetch posts in the view did load")
            DispatchQueue.main.async {
                self.reloadTableView()
            }
        }
    }
    
    @objc func refreshControlPulled(){
        postController.fetchPosts {
            print("Called the fetdh post function inside of the refresh control")
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.reloadTableView()
            }
        }
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        presentNewPostAlert()
    }
    
    func reloadTableView(){
        //            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.myTableView.reloadData()
        //            UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func presentNewPostAlert(){
        let alert =  UIAlertController(title: "New Post", message: "Enter info for new post", preferredStyle: .alert)
        alert.addTextField { (usernameTextField) in
            usernameTextField.placeholder = "Please enter username"
        }
        alert.addTextField { (messageTextField) in
            messageTextField.placeholder = "Enter post message"
        }
        let addAction = UIAlertAction(title: "Add Post", style: .default) { (_) in
            guard let username = alert.textFields?.first?.text, !username.isEmpty, let message = alert.textFields?.last?.text, !message.isEmpty else {
                print("Error unwrapping textfields in the alertController")
                self.presentErrorAlert()
                return }
            
            self.postController.addNewPostWith(username: username, text: message, completion: {
                
                DispatchQueue.main.async {
                    self.reloadTableView()
                }
                
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func presentErrorAlert(){
        let alert = UIAlertController(title: "Error", message: "Missing information. Please try again", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.presentNewPostAlert()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
}

extension PostListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        cell.textLabel?.text =  post.text
        let date = Date(timeIntervalSince1970: post.timestamp)
        cell.detailTextLabel?.text = "\(post.username) on \(formmatter.string(from: date))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //check if the  indexPath.row of the cell parameter is greater than  or equal to the number of posts currently loaded -1 on the postController. If so, call the fetchPosts function  with reset set to false. in the completion handler reload  the tableview
        guard indexPath.row >= postController.posts.count - 1 else {
            return
        }
        postController.fetchPosts(reset: false) {
            print("FETCHING POSTS AT THE END OF THE TABLE VIEW")
                        DispatchQueue.main.async {
                            self.reloadTableView()
                        }
        }
    }
    
}
