//
//  PostController.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import Foundation
import UIKit

class PostController {
    
    static let sharedController = PostController()
    
    var posts: [Post] = []
    
    func createMockData(){
        
        guard let image = UIImage(named: "musikverein") else {return}
        PostController.sharedController.createPost(image, caption: "Vienna!")
        PostController.sharedController.addCommentToPost("Austria", post: self.posts[0])
        
        PostController.sharedController.createPost(image, caption: "Germany")
        PostController.sharedController.addCommentToPost("Austria", post: self.posts[1])
        PostController.sharedController.addCommentToPost("Traveling around the world!", post: self.posts[1])
        
        
        
        
        
    }
    // Functions
    
    func createPost(image: UIImage, caption: String){
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return }
        let newPost = Post(photoData: imageData)
        addCommentToPost(caption, post: newPost)
        self.posts.append(newPost)
    }
    
    func addCommentToPost(text: String, post: Post){
        let newComment = Comment(text: text, post: post)
        post.comments.append(newComment)
    }
    
}
