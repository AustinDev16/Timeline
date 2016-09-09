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
    
    let cloudKitManager = CloudKitManager()
    
    
    var posts: [Post] = [] {
        didSet{
           let postNotification = NSNotification(name: "PostsHaveBeenUpdated", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(postNotification)
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
    // Functions
    
    func fetchPosts(){
        
        cloudKitManager.fetchRecordsWithType("post", recordFetchedBlock: nil) { (records, error) in
            if error == nil {
               
                guard let records = records else {return}
                dispatch_async(dispatch_get_main_queue(), {
                    print(records)
                    
                let fetchedPosts = records.flatMap({ Post(record: $0)})
                   _ = fetchedPosts.map{self.fetchCommentsForPost($0)}
                    let sortedPosts = fetchedPosts.sort { $0.0.timestamp.timeIntervalSince1970 > $0.1.timestamp.timeIntervalSince1970 }
                    self.posts = sortedPosts
                    print(self.posts.count)
                    
                   
                    
                    
                })
                
            } else {
                print("Error fetching. \(error?.localizedDescription)")
            }
        }
    }
    
    func fetchCommentsForPost(post: Post){
        
        guard let recordID = post.cloudKitRecordID else { print("No cloudKitrecord id on post"); return}
        //let predicate = NSPredicate(value: true)
        let predicate = NSPredicate(format: "post == %@", recordID)
        // Predicate that says, look for comments with this id in their "post" field
        cloudKitManager.fetchRecordsWithType("comment", predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            print("Back from comment search")
            print(records)
            print(error)
            if error == nil {
                guard let records = records else { return}
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let fetchedComments = records.map{Comment(record: $0)} as? [Comment]
                    if let fetchedComments = fetchedComments {
                        for comment in fetchedComments {
                            comment.post = post
                        }
                        post.comments = fetchedComments.sort {$0.0.timestamp.timeIntervalSince1970 < $0.1.timestamp.timeIntervalSince1970}
                        
                        print(post.comments.count)
                    }
                })
                
                
                
            } else {
                print("Error fetching comments for post: \(error?.localizedDescription)")
            }
        }
        
    }
    
    func createPost(image: UIImage, caption: String){
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        let newPost = Post(photoData: imageData)
        guard let newCKRecord = CKRecord(post: newPost) else {return}
        
        cloudKitManager.saveRecord(newCKRecord) { (record, error) in
            if error == nil{
                guard let record = record else {return}
                newPost.cloudKitRecordID = record.recordID
                newPost.record = record
                self.addCommentToPost(caption, post: newPost)
                //self.posts.append(newPost)
                dispatch_async(dispatch_get_main_queue()) {
                     self.posts.insert(newPost, atIndex: 0)
                }
               
                
            } else {
                print("Error creating post in CloudKit: \(error?.localizedDescription)")
            }
            
        }
        
      
    }
    
    func addCommentToPost(text: String, post: Post){
        let newComment = Comment(text: text, post: post)
       
    
        
        guard let newCKRecord = CKRecord(comment: newComment, post: post),
        let record = post.record  else {return}
        newCKRecord["post"] = CKReference(record: record, action: .DeleteSelf)
        
        cloudKitManager.saveRecord(newCKRecord) { (record, error) in
            if error == nil {
                guard let record = record else {return}
                newComment.cloudKitRecordID = record.recordID
                  post.comments.append(newComment)
            } else {
                print("Error adding comment: \(error?.localizedDescription)")
            }
        }
        
      
    }
    
}
