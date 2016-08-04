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


class Pin: NSManagedObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        set {
            lat = NSNumber(double: newValue.latitude)
            long = NSNumber(double: newValue.longitude)
        }
        get {
            return CLLocationCoordinate2D(latitude: lat as! Double, longitude: long as! Double)
        }
    }
    
    convenience init(lat: Double, long: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.lat = NSNumber(double: lat)
            self.long = NSNumber(double: long)
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}