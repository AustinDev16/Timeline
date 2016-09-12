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
    
    var unownedComments: [Comment] = []
    
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
    func syncedRecords(recordType: String) -> [CKReference?] {
        switch recordType{
        case "post":
            
            let syncedPosts = PostController.sharedController.posts.filter{$0.isSynced == true}
            let syncedRecords = syncedPosts.map { $0.cloudKitReference }
            return syncedRecords
            
            
            
        case "comment":
            
            let syncedComments = PostController.sharedController.posts.flatMap { $0.comments.filter { $0.isSynced == true } }
            let syncedRecords = syncedComments.map { $0.cloudKitReference }
            return syncedRecords
        default: return []
        }
    }
    
    func unsyncedRecords(recordType: String) -> [CloudKitSyncable]{
        switch recordType{
        case "post":
            let unsyncedRecords = PostController.sharedController.posts.filter{$0.isSynced != true}
            return unsyncedRecords
        case "comment":
            let unsyncedRecords = PostController.sharedController.posts.flatMap { $0.comments.filter { $0.isSynced != true } }
            return unsyncedRecords
        default: return []
        }
    }
    
    func fetchNewRecords(recordType: String, completion: () -> Void){
        
        guard let referencesToExclude = syncedRecords(recordType) as? [CKReference] else {completion(); return}
        
//        let predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referencesToExclude])
        //print(predicate)
        let predicate = NSPredicate(value: true)
        let recordFetchedBlock: ((record: CKRecord) -> Void)? = { record in
            switch record.recordType{
            case "post":
                if let newPost = Post(record: record){
                    dispatch_async(dispatch_get_main_queue(), {
                         PostController.sharedController.posts.insert(newPost, atIndex: 0)
                    })
                }
                case "comment":
                    if let newComment = Comment(record: record){
                        // add code here to implement any new comments
                        self.unownedComments.append(newComment)
                    }
                return
            default:
                return
            }
            
            
        }
        
        
        cloudKitManager.fetchRecordsWithType(recordType, predicate: predicate, recordFetchedBlock: recordFetchedBlock){ record, error in
            // finish up full batch
            
            dispatch_async(dispatch_get_main_queue(), {
                
                for comment in self.unownedComments {
                    let selectedPost = PostController.sharedController.posts.filter { $0.cloudKitRecordID == comment.cloudKitRecordID}
                    _ = selectedPost.map {
                        comment.post = $0
                        $0.comments.insert(comment, atIndex: 0)}
                }
                
                self.unownedComments = []
                completion()
                
                
            })
        }
    }
    
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
