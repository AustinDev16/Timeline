//
//  PostListTableViewController.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController, UISearchResultsUpdating {

    var searchController: UISearchController?
    
    @IBAction func refreshButtonTapped(sender: AnyObject) {
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PostController.sharedController.performFullSync()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
           PostController.sharedController.createMockData()
        tableView.reloadData()
        setUpSearchController()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateTableView), name: "postsArrayUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.toggleNetworkIndicator), name: "toggleNetworkIndicator", object: nil)
        
        toggleNetworkIndicator()
        PostController.sharedController.fetchPosts()
    }
    
    func updateTableView(){
        self.tableView.reloadData()
    }
    
    func toggleNetworkIndicator(){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = !UIApplication.sharedApplication().networkActivityIndicatorVisible
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }

  
    func setUpSearchController(){

        let storyboard = UIStoryboard(name: "Main", bundle:  nil)
        let resultController = storyboard.instantiateViewControllerWithIdentifier("resultsTVC")
        searchController = UISearchController(searchResultsController: resultController)
        guard let searchController = searchController else {return}
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search for a post"
        self.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text,
        resultController = searchController.searchResultsController as? SearchResultsTableViewController else {return}
        resultController.filteredResults = PostController.sharedController.posts.filter { $0.matchesSearchTerm(searchTerm.lowercaseString)}
        resultController.tableView.reloadData()
    }
    

    // MARK: - Table view data source


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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if segue.identifier == "toDetailFromExisting"{
            guard let indexPath = tableView.indexPathForSelectedRow,
            detailTVC = segue.destinationViewController as? PostDetailTableViewController else { return }
            
            let selectedPost = PostController.sharedController.posts[indexPath.row]
            detailTVC.post = selectedPost

            
        } else if segue.identifier == "toAddPost" {
            // segue for adding new post
        } else if segue.identifier == "toDetailFromSearch" {
            guard let selectedCell = sender as? PostTableViewCell,
                detailTVC = segue.destinationViewController as? PostDetailTableViewController else {return}
           
            detailTVC.post = selectedCell.post
        }
        
    }
    

}
