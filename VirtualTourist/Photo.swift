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
    var url: String?
    
    convenience init(text: String = "New Photo", context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.name = text
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    /*
     * Download image by url in background task
     */
//    func startLoadingImage(handler: (image : UIImage?, error: String?) -> Void) {
//        // Check in memory
//        
//        // Check in file system
//        
//        // Cancel existing task to prevent traffic flow
//        
//        task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: url)!)) { data, response, downloadError in
//            dispatch_async(dispatch_get_main_queue(), {
//                guard downloadError == nil else {
//                    print("Photo loading canceled")
//                    return handler(image: nil, error: "Photo loadnig canceled")
//                }
//                
//                guard let data = data, let image = UIImage(data: data) else {
//                    print("Photo not loaded")
//                    return handler(image: nil, error: "Photo not loaded")
//                }
//                
//                MemoryCache.set(image, forKey: self.filePath)
//                FileCache.set(image, forPath: self.filePath)
//                
//                print("Photo loaded from internet")
//                return handler(image: image, error: nil)
//            })
//        }
//        task!.resume()
//    }

}
