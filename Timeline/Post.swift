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

class Post: CloudKitSyncable {
    
    init(photoData: NSData, timestamp: NSDate = NSDate(), comments: [Comment] = []){
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
    }
    
    required init?(record: CKRecord){
        guard let photoData = record["photoURL"] as? CKAsset,
            let timestamp = record["timestamp"] as? NSDate else { return nil}
        self.photoData = NSData(contentsOfURL: photoData.fileURL)
        self.timestamp = timestamp
        self.comments = []
        self.cloudKitRecordID = record.recordID
        self.record = record
        
    }
    
    
    let photoData: NSData?
    let timestamp: NSDate
    var comments: [Comment] {
        didSet{
            let commentNotification = NSNotification(name: "CommentsUpdated", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(commentNotification)
        }
    }
    var cloudKitRecordID: CKRecordID?
    var recordType: String = "Post"
    
    var image: UIImage? {
        guard let photoData = photoData else { return UIImage() }
        return UIImage(data: photoData)
    }
    
    var isSynced: Bool { return cloudKitRecordID != nil}
    var cloudKitReference: CKReference? {
        guard let cloudKitRecordID = self.cloudKitRecordID else {return nil}
        return CKReference(recordID: cloudKitRecordID, action: .DeleteSelf)
    }
    
    var record: CKRecord?
    
    var temporaryPhotoURL: NSURL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension("jpg")
        
        photoData?.writeToURL(fileURL, atomically: true)
        
        return fileURL
    }
    
}

extension Post: SearchableObject {
    func matchesSearchTerm(searchTerm: String) -> Bool {
        let query: [Bool] = comments.flatMap {$0.matchesSearchTerm(searchTerm)}
        return query.contains(true) ? true : false
    }
}
