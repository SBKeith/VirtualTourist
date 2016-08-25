//
//  PhotoFrame+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 8/24/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PhotoFrame {

    @NSManaged var imageData: NSData?
    @NSManaged var photo: Photo?

}
