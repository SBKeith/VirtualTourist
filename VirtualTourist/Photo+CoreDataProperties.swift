//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 7/7/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var name: String?
    @NSManaged var pin: Pin?

}
