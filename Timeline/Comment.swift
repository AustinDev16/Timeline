//
//  Comment.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import Foundation
import CloudKit

class Comment: CloudKitSyncable{
    
    init(text: String, timestamp: NSDate = NSDate(), post: Post){
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    
    
    required init?(record: CKRecord){
        guard let text = record["text"] as? String,
            let timestamp = record["timestamp"] as? NSDate,
            let post = record["post"] as? Post else { return nil }
        
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.cloudKitRecordID = record.recordID
        
    }
    
    let text: String
    let timestamp: NSDate
    let post: Post
    var cloudKitRecordID: CKRecordID?
    var recordType: String = "Comment"
    var cloudKitReference: CKReference?{
        guard let cloudKitRecordID = self.cloudKitRecordID else {return nil}
        return CKReference(recordID: cloudKitRecordID, action: .DeleteSelf)
    }
    var isSynced: Bool { return cloudKitRecordID != nil }
    
}

extension Comment: SearchableObject {
    func matchesSearchTerm(searchTerm: String) -> Bool {
        return text.lowercaseString.containsString(searchTerm)
    }
}
