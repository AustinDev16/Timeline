//
//  CKRecordExtension.swift
//  Timeline
//
//  Created by Austin Blaser on 9/8/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import Foundation
import CloudKit

extension CKRecord {
    // for creating a CKRecord from a Post
    convenience init?(post: Post){
        self.init(recordType: post.recordType)
        
        self["timestamp"] = post.timestamp
        let tempURL = post.temporaryPhotoURL
        let tempAsset = CKAsset(fileURL: tempURL)
        self["photoURL"] = tempAsset
    }
    
    // for creating a CKRecord from a comment
    
    convenience init?(comment: Comment, post: Post){
        
        self.init(recordType: comment.recordType)
        
        self["text"] = comment.text
        self["timestamp"] = comment.timestamp
        
    }
}
