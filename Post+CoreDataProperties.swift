//
//  Post+CoreDataProperties.swift
//  Timeline
//
//  Created by Austin Blaser on 9/16/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Post {

    @NSManaged var timestamp: NSDate
    @NSManaged var photoData: NSData?
    @NSManaged var recordType: String
    @NSManaged var cloudKitRecordName: String
    @NSManaged var subscriptionID: String?

}
