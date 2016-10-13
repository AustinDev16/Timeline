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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedPost = filteredResults[indexPath.row]
        let selectedCell = tableView.cellForRow(at: indexPath) as? PostTableViewCell
        let selectedPost = filteredResults[(indexPath as NSIndexPath).row]
        selectedCell?.post = selectedPost
        self.presentingViewController?.performSegue(withIdentifier: "toDetailFromSearch", sender: selectedCell)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredResults.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as? PostTableViewCell
        let post = filteredResults[(indexPath as NSIndexPath).row] //as? Post
        
        
        cell?.postImageView.image = post.image

        // Configure the cell...

        return cell ?? UITableViewCell()
    }
    

 
  
    

}
