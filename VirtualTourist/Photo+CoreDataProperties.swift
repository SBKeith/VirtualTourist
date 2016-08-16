//
//  Photo+CoreDataProperties.swift
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

extension Photo {

    @NSManaged var url: String?
    @NSManaged var id: String?
    @NSManaged var pin: Pin?

}
