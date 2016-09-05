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
    
    // Functions
    
    func createPost(image: UIImage, caption: String){
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return }
        let newPost = Post(photoData: imageData)
        addCommentToPost(caption, post: newPost)
    }
    
    func addCommentToPost(text: String, post: Post){
        let newComment = Comment(text: text, post: post)
        post.comments.append(newComment)
    }
    
}
