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
            lat = newValue.latitude
            long = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
    }

    convenience init(lat: Double, long: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.lat = lat
            self.long = long
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
