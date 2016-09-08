//
//  CloudKitSyncable.swift
//  Timeline
//
//  Created by Austin Blaser on 9/7/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitSyncable{
    init?(record: CKRecord)
    
    var cloudKitRecordID: CKRecordID? { get set }
    var recordType: String { get }
    var isSynced: Bool {get }// helper variable to determine if a CloudKitSyncable has a CKRecordID, which we can use to say that the record has been saved to the server
   var cloudKitReference: CKReference? {get } // a computed property that returns a CKReference to the object in CloudKit
}

