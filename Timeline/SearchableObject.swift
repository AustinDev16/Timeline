//
//  SearchableObject.swift
//  Timeline
//
//  Created by Austin Blaser on 9/6/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import Foundation


protocol SearchableObject {
    
    func matchesSearchTerm(_ searchTerm: String) -> Bool
    
}
