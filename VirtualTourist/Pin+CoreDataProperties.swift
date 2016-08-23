//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 8/16/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var lat: NSNumber?
    @NSManaged var long: NSNumber?
    @NSManaged var photos: [Photo]?

}
