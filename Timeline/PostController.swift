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
    
    
    var posts: [Post] = []
    
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
    
    func createPost(image: UIImage, caption: String){
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        let newPost = Post(photoData: imageData)
        guard let newCKRecord = CKRecord(post: newPost) else {return}
        
        cloudKitManager.saveRecord(newCKRecord) { (record, error) in
            if error == nil{
                guard let record = record else {return}
                newPost.cloudKitRecordID = record.recordID
                self.addCommentToPost(caption, post: newPost, postRecord: newCKRecord)
                //self.posts.append(newPost)
                dispatch_async(dispatch_get_main_queue()) {
                     self.posts.insert(newPost, atIndex: 0)
                }
               
                
            } else {
                print("Error creating post in CloudKit: \(error?.localizedDescription)")
            }
            
        }
        
      
    }
    
    func addCommentToPost(text: String, post: Post, postRecord: CKRecord?){
        let newComment = Comment(text: text, post: post)
        var recordToReference: CKRecord?
        if let postRecord = postRecord { recordToReference = postRecord } else {
            guard let recordID = post.cloudKitRecordID else {return}
            cloudKitManager.fetchRecordWithID(recordID, completion: { (record, error) in
                if error != nil{
                    guard let record = record else {return}
                    recordToReference = record
                } else {
                    print("Error fetching record from cloudKit: \(error?.localizedDescription)")
                }
            })
        }
        
        guard let newCKRecord = CKRecord(comment: newComment, post: post),
        let record = recordToReference else {return}
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
