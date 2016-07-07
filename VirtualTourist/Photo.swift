//
//  Photo.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 7/7/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

    convenience init(text: String = "New Photo", context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.name = text
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
