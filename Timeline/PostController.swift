//
//  PostController.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class PostController {
    
    static let sharedController = PostController()
    
    var posts: [Post] = [] {
        didSet{
            dispatch_async(dispatch_get_main_queue(), {
                let notification = NSNotification(name: "postsArrayUpdated", object: nil)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            })
        }
    }
    
    func createMockData(){
        
        guard let image = UIImage(named: "musikverein") else {return}
        PostController.sharedController.createPost(image, caption: "Vienna!")
        PostController.sharedController.addCommentToPost("Austria", post: self.posts[0])
        
        PostController.sharedController.createPost(image, caption: "Germany")
        PostController.sharedController.addCommentToPost("Austria", post: self.posts[1])
        PostController.sharedController.addCommentToPost("Traveling around the world!", post: self.posts[1])
        
    }
    // MARK: OnDevice Functions
    
    func createPost(image: UIImage, caption: String){
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return }
        let newPost = Post(photoData: imageData)
        addCommentToPost(caption, post: newPost)
        //self.posts.append(newPost)
        self.posts.insert(newPost, atIndex: 0)
    }
    
    func addCommentToPost(text: String, post: Post){
        let newComment = Comment(text: text, post: post)
        post.comments.append(newComment)
    }
    
    // MARK: CloudKitRelated
    
    func fetchPosts(){ // Fetches all posts and comments upon launch of the app
    
    }
    
    func pushUnsyncedPosts(){ // Pushes any local changes that haven't been synced
        
    }
    
    func fetchNewPosts(){ // Fetches any new posts from the cloud, and corresponding comments
    
    }
    
    func fetchNewComments(){ // Fetches any new comments made to existing posts.
        
    }
    
    func performFullSync(){ // pushes local changes, downloads any new content
        pushUnsyncedPosts()
        fetchNewPosts()
        fetchNewComments()
    }
    
    func returnPostFromCKReference(postReference: CKReference) -> Post? {
        // Grabs a Post object by querying its recordID
        let recordID = postReference.recordID
        return self.posts.filter{ $0.cloudKitRecordID == recordID }.first
    }
    
}
