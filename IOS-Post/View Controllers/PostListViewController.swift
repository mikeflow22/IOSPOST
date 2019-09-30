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
    
    func reloadTableView(){
//            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.myTableView.reloadData()
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
    
    
    
}
