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
        
//        guard let image = UIImage(named: "musikverein") else {return}
//        PostController.sharedController.createPost(image, caption: "Vienna!")
//        PostController.sharedController.addCommentToPost("Austria", post: self.posts[0])
//        
//        PostController.sharedController.createPost(image, caption: "Germany")
//        PostController.sharedController.addCommentToPost("Austria", post: self.posts[1])
//        PostController.sharedController.addCommentToPost("Traveling around the world!", post: self.posts[1])
        
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
        let perPostCompletion: (record: CKRecord) -> Void = { record in
            if let newPost = Post(record: record) {
                    PostController.sharedController.posts.append(newPost)
            }
        }
        
        let predicate = NSPredicate(value: true)
        CloudKitManager.sharedController.fetchRecordsWithType("post", predicate: predicate, recordFetchedBlock: perPostCompletion) { (records, error) in
            if error != nil {
                print("Error fetching records: \(error?.localizedDescription)")
            } else {
                // Begin fetch for comments
                _ = PostController.sharedController.posts.map { self.getCommentsForPost($0) }
                let notification = NSNotification(name: "toggleNetworkIndicator", object: nil)
               
                NSNotificationCenter.defaultCenter().postNotification(notification)
            }
        }
    }
    
    func getCommentsForPost(post: Post){
        guard let recordID = post.cloudKitRecordID else {return}
        
        let predicate = NSPredicate(format: "post == %@", recordID)
        CloudKitManager.sharedController.fetchRecordsWithType("comment", predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if error != nil {
                print("Error fetching comments: \(error?.localizedDescription)")
            } else {
                guard let records = records else {return}
                let comments = records.map { Comment(record: $0) }
                guard let unwrappedComments = comments as? [Comment] else {return}
                let sortedComments = unwrappedComments.sort {$0.0.timestamp.timeIntervalSince1970 < $0.1.timestamp.timeIntervalSince1970 }
                post.comments = sortedComments
            }
        }
       
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
