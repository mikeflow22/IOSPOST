//
//  PostListViewController.swift
//  IOS-Post
//
//  Created by Michael Flowers on 9/30/19.
//  Copyright © 2019 Michael Flowers. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController {

    var postController: PostController()
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
    }

}

extension PostListViewController: UITableViewDelegate, UITableViewDataSource {
    
}
