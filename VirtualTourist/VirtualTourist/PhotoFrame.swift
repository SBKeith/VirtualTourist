//
//  PhotoFrame.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 8/24/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//

import Foundation
import CoreData


class PhotoFrame: NSManagedObject {

    var imgData: NSData {
        get {
            return NSData(data: imageData!)
        }
    }
}