//
//  FlickrNetworkManager.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 8/9/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FlickrNetworkManager: NetworkManagerCalls {
    
    // Create singleton instance 
    static let sharedNetworkManager = FlickrNetworkManager()
    
    var task: URLSessionTask? = nil
    
    let flickrAPI_URL = "https://api.flickr.com/services/rest/"
    let myAPIKey = "4d0d57db70fdad9b02f3e16eea887f56"
    
    var randomPage: Int {
        return Int(arc4random_uniform(50) + 1)
    }
    
    func bboxString(_ lat: Double, long: Double) -> String {
        
        // ensure bbox is bounded by minimum and maximums
        let BOUNDING_BOX_HALF_WIDTH = 1.0, BOUNDING_BOX_HALF_HEIGHT = 1.0
        let LAT_MIN = -90.0, LAT_MAX = 90.0
        let LON_MIN = -180.0, LON_MAX = 180.0
        
        // Set mins and maxs
        let bottom_left_lon = max(long - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(lat - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(long + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(lat + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
// MARK: ADD INFO TO COREDATA METHODS
    func addNewPhotos(_ pin: Pin, handler: @escaping (_ error: String?) -> Void) {
        
        getPhotosUsingCoordinates((pin.coordinate.latitude), long: (pin.coordinate.longitude)) { (photos, error) -> Void in
            DispatchQueue.main.async(execute: {
                
                var photoTemp: Photo?
                
                print("Getting new photos for dropped pin...")
                
                // Add web URLs and Pin(s) only at this point...
                if photoTemp == nil {
                    for photo in photos! {
                        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
                            photoTemp = Photo(entity: entity, insertInto: context)
                            photoTemp?.url = photo["url_m"] as? String
                            photoTemp?.pin = pin
                        }
                    }
                }
                return handler(nil)
            })
        }
    }
    
// MARK: LOAD PHOTOS THAT ARE NOT SAVED IN COREDATA
    
    // Load photos from URLs
    func loadNewPhoto(_ indexPath: IndexPath, photosArray: [Photo], handler: @escaping (_ image: UIImage?, _ data: Data?, _ error: String) -> Void) {

        if photosArray.count > 0 {
            if photosArray[indexPath.item].url != nil {
                task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: photosArray[indexPath.item].url!)!), completionHandler: { data, response, downloadError in
                    DispatchQueue.main.async(execute: {
                        
                        guard let data = data, let image = UIImage(data: data) else {
                            print("Photo not loaded")
                            return handler(nil, nil, "Photo not loaded")
                        }
                        
                        return handler(image, data, "")
                    })
                }) 
                task!.resume()
            }
        }
    }

    // Get photo data from touch coordinates
    func getPhotosUsingCoordinates(_ lat: Double, long: Double, page: Int = 1, handler: @escaping (_ photos: [[String : AnyObject]]?, _ error: String?) -> Void) {
        
        print(page)
        
        
        let params = [
            "method": "flickr.photos.search",
            "api_key": myAPIKey,
            "bbox": bboxString(lat, long: long),
            "safe_search": "1",
            "extras": "url_m",
            "format": "json",
            "nojsoncallback": "1",
            "per_page": "21",
            "page": String(page)
        ]
        
        let request = setupRequest("\(flickrAPI_URL)", params: params as [String : AnyObject])
        
        getRequest(request) { (result, error) -> Void in
            guard error == nil else {
                handler(nil, error)
                return
            }
            guard let data = result!["photos"] as? [String : AnyObject] else {
                print("No photos were found!")
                handler(nil, "Data capture error")
                return
            }
            guard let photos = data["photo"] as? [[String: AnyObject]] else {
                print("No photos were found!")
                handler(nil, "Data capture eror")
                return
            }
            handler(photos, nil)
        }
    }
}
