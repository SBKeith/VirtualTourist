//
//  Photo.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 7/7/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Photo: NSManagedObject {

    var task: NSURLSessionTask? = nil
    
    convenience init(id: String, url: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            
            self.id = id
            self.url = url
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    // Create a 'Photo'
    convenience init(photoDictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        self.init(entity: ent!, insertIntoManagedObjectContext: context)
        
        self.id = photoDictionary["id"] as? String
        self.url = photoDictionary["url_m"] as? String
    }
}
