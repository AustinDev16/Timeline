//
//  Comment.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import Foundation
import CloudKit

class Comment: CloudKitSyncable {
    
    init(text: String, timestamp: Date = Date(), post: Post){
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.recordType = "comment"
        self.cloudKitRecordID = nil
    }
    
    required init?(record: CKRecord){
        guard let text = record["text"] as? String,
            let timestamp = record["timestamp"] as? Date,
            let postReference = record["post"] as? CKReference,
            let recordType = record["recordType"] as? String,
            let cloudKitRecordID = record["recordID"] as? CKRecordID,
            let post = PostController.sharedController.returnPostFromCKReference(postReference) else {return nil}
        
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.recordType = recordType
        self.cloudKitRecordID = cloudKitRecordID
    }
    
    let text: String
    let timestamp: Date
    let post: Post
    
    // CloudKitSyncable
    
    var recordType: String
    var cloudKitRecordID: CKRecordID?
    var isSynced: Bool { return cloudKitRecordID != nil }

}

extension CKRecord {
    convenience init?(comment: Comment){
        self.init(recordType: comment.recordType)
        self["text"] = comment.text as CKRecordValue?
        self["timestamp"] = comment.timestamp as CKRecordValue?
        guard let postReference = comment.post.cloudKitRecordID else { return}
        self["post"] = CKReference(recordID: postReference, action: .deleteSelf)
        
    }
}

extension Comment: SearchableObject {
    func matchesSearchTerm(_ searchTerm: String) -> Bool {
        return text.lowercased().contains(searchTerm)
    }
}

