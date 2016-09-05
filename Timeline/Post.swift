//
//  Post.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import Foundation
import UIKit

class Post {
    
    init(photoData: NSData, timestamp: NSDate = NSDate(), comments: [Comment] = []){
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
    }
    
    let photoData: NSData?
    let timestamp: NSDate
    var comments: [Comment]
    
    var image: UIImage? {
        guard let photoData = photoData else { return UIImage() }
        return UIImage(data: photoData)
    }
    
}
