//
//  Comment.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import Foundation

class Comment{
    
    init(text: String, timestamp: NSDate = NSDate(), post: Post){
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    
    let text: String
    let timestamp: NSDate
    let post: Post
}

extension Comment: SearchableObject {
    func matchesSearchTerm(searchTerm: String) -> Bool {
        return text.containsString(searchTerm)
    }
}

