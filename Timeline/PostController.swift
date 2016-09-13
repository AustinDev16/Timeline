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
    
    var newPostsFromCloud: [Post] = []
    
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
        //addCommentToPost(caption, post: newPost)
        //self.posts.append(newPost)
        self.posts.insert(newPost, atIndex: 0)
        
        // Push new post to CloudKit
        guard let newPostRecord = CKRecord(post: newPost) else { return}
        CloudKitManager.sharedController.saveRecord(newPostRecord) { (record, error) in
            if error != nil {
                print("Error pushing post to cloud: \(error?.localizedDescription)")
            } else {
                guard let record = record else {return}
                newPost.cloudKitRecordID = record.recordID
                // Create comment record
                self.addCommentToPost(caption, post: newPost)
            }
        }
    }
    
    func addCommentToPost(text: String, post: Post){
        let newComment = Comment(text: text, post: post)
        post.comments.append(newComment)
        guard let commentRecord = CKRecord(comment: newComment) else {return}
        CloudKitManager.sharedController.saveRecord(commentRecord) { (record, error) in
            if error != nil {
                print("Error pushing comment to cloud: \(error?.localizedDescription)")
            } else {
                guard let record = record else { return}
                newComment.cloudKitRecordID = record.recordID
            }
        }
    }
    
    // MARK: CloudKitRelated
    func getUnsyncedObjects(type: String) -> [AnyObject]{
        switch type{
        case "post":
            let unsyncedPosts = PostController.sharedController.posts.filter{ $0.isSynced != true}
            return unsyncedPosts
        case "comment":
            let unsyncedComments = PostController.sharedController.posts.flatMap{ $0.comments}.filter{ $0.isSynced != true }
            return unsyncedComments

        default:
            return []
        }
    }
    
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
    
    func fetchNewPosts(references: [CKReference], completion: ([CKRecord] -> Void)){ // Fetches any new posts from the cloud, and corresponding comments
        let perPostCompletion: (record: CKRecord) -> Void = { record in
            if let newPost = Post(record: record) {
                PostController.sharedController.newPostsFromCloud.append(newPost)
            }
        }
        
        let predicate = NSPredicate(format: "NOT(recordID IN %@)", references)
        CloudKitManager.sharedController.fetchRecordsWithType("post", predicate: predicate, recordFetchedBlock: perPostCompletion) { (records, error) in
            defer { completion([])}
            if error != nil {
                print("Error fetching new posts: \(error?.localizedDescription)")
                return
            } else {
                // fetch comments for new posts
                _ = PostController.sharedController.newPostsFromCloud.map { self.getCommentsForPost($0) }
                
            }
        }
    
    }
    
    func fetchNewComments(references: [CKReference], completion: ([CKRecord] -> Void)){ // Fetches any new comments made to existing posts.
        
          let predicate = NSPredicate(format: "NOT(recordID IN %@)", references)
    CloudKitManager.sharedController.fetchRecordsWithType("comment", predicate: predicate, recordFetchedBlock: nil) { (records, error) in
        
            if error != nil {
                print("Error fetching new unpaired comments: \(error?.localizedDescription)")
            } else {
                guard let records = records else { return}
                let unassignedComments = records.flatMap{ Comment(record: $0)}
                
                for comment in unassignedComments {
                    let referencePost = comment.post
                    referencePost.comments.append(comment)
                }
                completion([])
            }
        }
        
        
        
        
    }
    
    func performFullSync(){ // pushes local changes, downloads any new content
        // Check first for any unsaved local records
        guard let unsyncedPosts = getUnsyncedObjects("post") as? [Post] else {return}
        guard let unsyncedComments = getUnsyncedObjects("comment") as? [Comment] else {return}
        if unsyncedPosts.count > 0 || unsyncedComments.count > 0 {
            // create new records and sync them here
            pushUnsyncedPosts()
        }
        // Generate a list of all records on device as CKReference and pass to CloudKit
        
        let fullPostReferenceList = PostController.sharedController.posts.map{ CKReference(recordID: $0.cloudKitRecordID!, action: .DeleteSelf) }
        
        newPostsFromCloud = []
        
        fetchNewPosts(fullPostReferenceList){ records in
           _ = PostController.sharedController.newPostsFromCloud.map{ PostController.sharedController.posts.append($0)}
            PostController.sharedController.newPostsFromCloud = []
            // Now search for any new comments for existing posts
            
            let fullCommentList = PostController.sharedController.posts.flatMap{ $0.comments}
            let fullCommentReferenceList = fullCommentList.map{ CKReference(recordID: $0.cloudKitRecordID!, action: .DeleteSelf)}
            
            self.fetchNewComments(fullCommentReferenceList){ records in
                
                dispatch_async(dispatch_get_main_queue(), {
                    let notification = NSNotification(name: "toggleNetworkIndicator", object: nil)
                    
                    NSNotificationCenter.defaultCenter().postNotification(notification)

                })
            }
            
        }
       
    }
    
    func returnPostFromCKReference(postReference: CKReference) -> Post? {
        // Grabs a Post object by querying its recordID
        let recordID = postReference.recordID
        return self.posts.filter{ $0.cloudKitRecordID == recordID }.first
    }
    
}
