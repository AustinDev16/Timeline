//
//  SearchResultsTableViewController.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    
    var filteredResults: [Post] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.estimatedRowHeight = 160
//        tableView.rowHeight = UITableViewAutomaticDimension

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let selectedPost = filteredResults[indexPath.row]
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? PostTableViewCell
        let selectedPost = filteredResults[indexPath.row]
        selectedCell?.post = selectedPost
        self.presentingViewController?.performSegueWithIdentifier("toDetailFromSearch", sender: selectedCell)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredResults.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 160.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath) as? PostTableViewCell
        let post = filteredResults[indexPath.row] //as? Post
        
        
        cell?.postImageView.image = post.image

        // Configure the cell...

        return cell ?? UITableViewCell()
    }
    

 
  
    

}
