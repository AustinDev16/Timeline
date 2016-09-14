//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    
    @IBOutlet weak var followButton: UIBarButtonItem!
    
    var post: Post?
    var canToggleSubscribing: Bool = true
    
    func updateWithPost(){
        detailImageView.image = self.post?.image
        tableView.reloadData()
        
        if post?.subscriptionID == nil {
            self.followButton.title = "Follow Post"
        } else {
            self.followButton.title = "Unfollow Post"
        }
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 25
        tableView.rowHeight = UITableViewAutomaticDimension
        updateWithPost()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateCommentsTableViewData), name: "commentsUpdated", object: nil)
    }
    
    func updateCommentsTableViewData(){
        self.tableView.reloadData()
    }

    @IBAction func commentButtonTapped(sender: AnyObject) {
        // Configure Alert Controller to populate a new comment
        
        let commentAlertController = UIAlertController(title: "New Comment", message: nil, preferredStyle: .Alert)
        commentAlertController.addTextFieldWithConfigurationHandler { (commentTextField) in
            commentTextField.placeholder = "Leave a comment:"
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let post = UIAlertAction(title: "Add comment", style: .Default) { (_) in
            guard let post = self.post,
                commentTextField = commentAlertController.textFields,
                newComment = commentTextField[0].text where newComment.characters.count > 0
                else {return}
            
            PostController.sharedController.addCommentToPost(newComment, post: post)
            commentAlertController.resignFirstResponder()
            self.tableView.reloadData()
        }
        
        commentAlertController.addAction(cancel)
        commentAlertController.addAction(post)
        
        presentViewController(commentAlertController, animated: true, completion: nil)
        
    }

    @IBAction func sendButtonTapped(sender: AnyObject) {
    }

    @IBAction func followPostButtonTapped(sender: AnyObject) {
        guard let post = self.post else { return}
        
        if canToggleSubscribing {
            
            let subscriptionID = post.subscriptionID
            switch subscriptionID {
            case nil: // means no subscription exists yet for this post
                canToggleSubscribing = false
                PostController.sharedController.subscribeToFollowPost("comment", post: post){success in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.canToggleSubscribing = true
                        if success {
                            // toggle button
                            self.followButton.title = "Unfollow Post"
                        }
                        
                    })
                
                }
            default: // means there is a subscription for this post
                canToggleSubscribing = false
              PostController.sharedController.unsubscribeFromPost("comment", post: post){success in
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.canToggleSubscribing = true
                    if success {
                        // toggle button
                        self.followButton.title = "Follow Post"
                    }
                })
                
                }
            }
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return post?.comments.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
        let comment = post?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        formatter.doesRelativeDateFormatting = true
        guard let date = comment?.timestamp else {return UITableViewCell()}
        cell.detailTextLabel?.text = formatter.stringFromDate(date)//String(comment?.timestamp)
        // Configure the cell...

        return cell
    }
    
//    let dateFormatter: NSDateFormatter = {
//        let formatter = NSDateFormatter()
//        formatter.dateStyle = .ShortStyle
//        formatter.timeStyle = .ShortStyle
//        formatter.doesRelativeDateFormatting = true
//        return formatter
//    }()
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
