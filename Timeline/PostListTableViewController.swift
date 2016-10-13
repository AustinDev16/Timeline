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
    
    @IBAction func refreshButtonTapped(_ sender: AnyObject) {
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PostController.sharedController.performFullSync()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
           PostController.sharedController.createMockData()
        tableView.reloadData()
        setUpSearchController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTableView), name: NSNotification.Name(rawValue: "postsArrayUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleNetworkIndicator), name: NSNotification.Name(rawValue: "toggleNetworkIndicator"), object: nil)
        
        toggleNetworkIndicator()
        PostController.sharedController.fetchPosts()
    }
    
    func updateTableView(){
        self.tableView.reloadData()
    }
    
    func toggleNetworkIndicator(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = !UIApplication.shared.isNetworkActivityIndicatorVisible
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

  
    func setUpSearchController(){

        let storyboard = UIStoryboard(name: "Main", bundle:  nil)
        let resultController = storyboard.instantiateViewController(withIdentifier: "resultsTVC")
        searchController = UISearchController(searchResultsController: resultController)
        guard let searchController = searchController else {return}
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search for a post"
        self.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text,
        let resultController = searchController.searchResultsController as? SearchResultsTableViewController else {return}
        resultController.filteredResults = PostController.sharedController.posts.filter { $0.matchesSearchTerm(searchTerm.lowercased())}
        resultController.tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return PostController.sharedController.posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell
        let post = PostController.sharedController.posts[(indexPath as NSIndexPath).row]
        
        cell?.updateWithPost(post)
        

        // Configure the cell...

        return cell ?? UITableViewCell()
    }
    

  

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "toDetailFromExisting"{
            guard let indexPath = tableView.indexPathForSelectedRow,
            let detailTVC = segue.destination as? PostDetailTableViewController else { return }
            
            let selectedPost = PostController.sharedController.posts[(indexPath as NSIndexPath).row]
            detailTVC.post = selectedPost

            
        } else if segue.identifier == "toAddPost" {
            // segue for adding new post
        } else if segue.identifier == "toDetailFromSearch" {
            guard let selectedCell = sender as? PostTableViewCell,
                let detailTVC = segue.destination as? PostDetailTableViewController else {return}
           
            detailTVC.post = selectedCell.post
        }
        
    }
    

}
