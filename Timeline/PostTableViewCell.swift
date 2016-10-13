//
//  PostTableViewCell.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    var post: Post?
    
    @IBOutlet weak var postImageView: UIImageView!
    
    func updateWithPost(_ post: Post){
        self.postImageView.image = post.image
    }
  

}
