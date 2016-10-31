//
//  Photo.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 8/24/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

    convenience init(id: String, url: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            
            self.id = id
            self.url = url
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
