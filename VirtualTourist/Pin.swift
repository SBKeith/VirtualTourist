//
//  Pin.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 7/7/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject {
    convenience init(lat: Float, long: Float, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.lat = lat
            self.long = long
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat as! Double, longitude: long as! Double)
    }
}
