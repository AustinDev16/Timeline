//
//  Comment+CoreDataProperties.swift
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

extension Comment {

    @NSManaged var text: String
    @NSManaged var timestamp: NSDate
    @NSManaged var postRecordName: String
    @NSManaged var recordType: String
    @NSManaged var cloudKitRecordName: String

}
