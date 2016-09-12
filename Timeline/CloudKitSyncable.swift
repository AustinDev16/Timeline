//
//  CloudKitSyncable.swift
//  Timeline
//
//  Created by Austin Blaser on 9/12/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitSyncable{
   var isSynced: Bool { get }
   var recordType: String { get set}
    var cloudKitRecordID: CKRecordID? {get set}
 //   var subscriptionID: CKReference {get set }
     init?(record: CKRecord)
    
}
