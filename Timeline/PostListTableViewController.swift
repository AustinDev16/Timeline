//
//  PostListTableViewController.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }

  

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return PostController.sharedController.posts.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as? PostTableViewCell
        let post = PostController.sharedController.posts[indexPath.row]
        
        cell?.updateWithPost(post)
        

        // Configure the cell...

        return cell ?? UITableViewCell()
    }
    

  

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if segue.identifier == "toDetailFromExisting"{
            guard let indexPath = tableView.indexPathForSelectedRow,
            detailTVC = segue.destinationViewController as? PostDetailTableViewController else { return }
            
            let selectedPost = PostController.sharedController.posts[indexPath.row]
            detailTVC.post = selectedPost

            
        } else if segue.identifier == "toAddPost" {
            // segue for adding new post
        }
        
    }
    

}
