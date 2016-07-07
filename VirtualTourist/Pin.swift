//
//  Pin.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 7/7/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {


    convenience init(lat: Float = 44.0, long: Float = -88.5, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
//            self.latitude = lat
//            self.longitude = long
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
