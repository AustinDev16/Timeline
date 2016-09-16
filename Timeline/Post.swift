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
import CoreData

class Post: NSManagedObject, CloudKitSyncable{
    
    init(photoData: NSData, timestamp: NSDate = NSDate(), comments: [Comment] = []){
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
        self.cloudKitRecordID = nil
        self.recordType = "post"
        //self.subscriptionID = nil
    }
    
    required init?(record: CKRecord){ //From CloudKit
        guard let photoURL = record["photoURL"] as? CKAsset,
            let timestamp = record["timestamp"] as? NSDate,
            let recordID = record["recordID"] as? CKRecordID,
            let recordType = record["recordType"] as? String
            else {return nil}
        
        self.photoData = NSData(contentsOfURL: photoURL.fileURL)
        self.timestamp = timestamp
        self.cloudKitRecordID = recordID
        self.recordType = recordType
        self.comments = []
        self.subscriptionID = record["subscriptionID"] as? String
        print(self.subscriptionID)
        self.cloudKitRecord = record
    }
    
    //let photoData: NSData?
    //let timestamp: NSDate
     var comments: [Comment] {
        didSet{
            dispatch_async(dispatch_get_main_queue(), {
                let notification = NSNotification(name: "commentsUpdated", object: nil)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            })
        }
    }
    
    var image: UIImage? {
        guard let photoData = photoData else { return UIImage() }
        return UIImage(data: photoData)
    }
    
    //CloudKitSyncable
    
    var cloudKitRecord: CKRecord?
    //var recordType: String
    var cloudKitRecordID: CKRecordID?
    var isSynced: Bool { return cloudKitRecordID != nil }
    //var subscriptionID: String?
    private var temporaryPhotoURL: NSURL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension("jpg")
        
        photoData?.writeToURL(fileURL, atomically: true)
        
        return fileURL
    }

}

extension CKRecord{
    convenience init?(post: Post){
        self.init(recordType: post.recordType)
        self["timestamp"] = post.timestamp
        self["photoURL"] = CKAsset(fileURL: post.temporaryPhotoURL)
        self["subscriptionID"] = post.subscriptionID
    }
}

extension Post: SearchableObject {
    func matchesSearchTerm(searchTerm: String) -> Bool {
        let query: [Bool] = comments.flatMap {$0.matchesSearchTerm(searchTerm)}
        return query.contains(true) ? true : false
    }
}
