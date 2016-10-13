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
    
    init(photoData: Data, timestamp: Date = Date(), comments: [Comment] = []){
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
        self.cloudKitRecordID = nil
        self.recordType = "post"
        //self.subscriptionID = nil
    }
    
    required init?(record: CKRecord){ //From CloudKit
        guard let photoURL = record["photoURL"] as? CKAsset,
            let timestamp = record["timestamp"] as? Date,
            let recordID = record["recordID"] as? CKRecordID,
            let recordType = record["recordType"] as? String
            else {return nil}
        
        self.photoData = try? Data(contentsOf: photoURL.fileURL)
        self.timestamp = timestamp
        self.cloudKitRecordID = recordID
        self.recordType = recordType
        self.comments = []
        self.subscriptionID = record["subscriptionID"] as? String
        print(self.subscriptionID)
        self.cloudKitRecord = record
    }
    
    let photoData: Data?
    let timestamp: Date
    var comments: [Comment] {
        didSet{
            DispatchQueue.main.async(execute: {
                let notification = Notification(name: Notification.Name(rawValue: "commentsUpdated"), object: nil)
                NotificationCenter.default.post(notification)
            })
        }
    }
    
    var image: UIImage? {
        guard let photoData = photoData else { return UIImage() }
        return UIImage(data: photoData)
    }
    
    //CloudKitSyncable
    
    var cloudKitRecord: CKRecord?
    var recordType: String
    var cloudKitRecordID: CKRecordID?
    var isSynced: Bool { return cloudKitRecordID != nil }
    var subscriptionID: String?
    fileprivate var temporaryPhotoURL: URL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        try? photoData?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }

}

extension CKRecord{
    convenience init?(post: Post){
        self.init(recordType: post.recordType)
        self["timestamp"] = post.timestamp as CKRecordValue?
        self["photoURL"] = CKAsset(fileURL: post.temporaryPhotoURL)
        self["subscriptionID"] = post.subscriptionID as CKRecordValue?
    }
}

extension Post: SearchableObject {
    func matchesSearchTerm(_ searchTerm: String) -> Bool {
        let query: [Bool] = comments.flatMap {$0.matchesSearchTerm(searchTerm)}
        return query.contains(true) ? true : false
    }
}
