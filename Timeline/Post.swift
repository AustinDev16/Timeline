//
//  Post.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Post: CloudKitSyncable{
    
    init(photoData: NSData, timestamp: NSDate = NSDate(), comments: [Comment] = []){
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
        self.cloudKitRecordID = nil
        self.recordType = "post"
    }
    
    required init?(record: CKRecord){ //From CloudKit
        guard let photoURL = record["photo"] as? CKAsset,
            let timestamp = record["timestamp"] as? NSDate,
            let recordID = record["recordID"] as? CKRecordID,
            let recordType = record["recordType"] as? String else {return nil}
        
        self.photoData = NSData(contentsOfURL: photoURL.fileURL)
        self.timestamp = timestamp
        self.cloudKitRecordID = recordID
        self.recordType = recordType
        self.comments = []
    }
    
    let photoData: NSData?
    let timestamp: NSDate
    var comments: [Comment]
    
    var image: UIImage? {
        guard let photoData = photoData else { return UIImage() }
        return UIImage(data: photoData)
    }
    
    //CloudKitSyncable

    var recordType: String
    var cloudKitRecordID: CKRecordID?
    var isSynced: Bool { return cloudKitRecordID != nil }

}

extension Post: SearchableObject {
    func matchesSearchTerm(searchTerm: String) -> Bool {
        let query: [Bool] = comments.flatMap {$0.matchesSearchTerm(searchTerm)}
        return query.contains(true) ? true : false
    }
}
