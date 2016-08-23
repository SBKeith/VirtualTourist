//
//  FlickrNetworkManager.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 8/9/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//

import Foundation
import CoreData

class FlickrNetworkManager: NetworkManagerCalls {
    
    // Create singleton instance 
    static let sharedNetworkManager = FlickrNetworkManager()
    
    let flickrAPI_URL = "https://api.flickr.com/services/rest/"
    let myAPIKey = "4d0d57db70fdad9b02f3e16eea887f56"
    
    func bboxString(lat: Double, long: Double) -> String {
        
        let BOUNDING_BOX_HALF_WIDTH = 1.0
        let BOUNDING_BOX_HALF_HEIGHT = 1.0
        let LAT_MIN = -90.0
        let LAT_MAX = 90.0
        let LON_MIN = -180.0
        let LON_MAX = 180.0
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(long - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(lat - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(long + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(lat + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
        
//        // ensure bbox is bounded by minimum and maximums
//        let k_Lat_Min = -90.0, k_Lat_Max = 90.0
//        let k_Lon_Min = -180.0, k_Lon_Max = 180.0
//        let k_BBoxHalfWidth = 1.0, k_BBoxHalfHeight = 1.0
//        
//        // Set mins and maxs
//        let minimumLon = max(long - k_BBoxHalfWidth, k_Lon_Min)
//        let minimumLat = max(lat - k_BBoxHalfHeight, k_Lat_Min)
//        let maximumLon = min(long - k_BBoxHalfHeight, k_Lon_Max)
//        let maximumLat = min(lat - k_BBoxHalfHeight, k_Lat_Max)
//        
//        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    func addNewPhotos(pin: Pin, handler: (error: String?) -> Void) {
        
        getPhotosUsingCoordinates((pin.coordinate.latitude), long: (pin.coordinate.longitude)) { (photos, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                
                var photoTemp: Photo?
                
                if photoTemp == nil {
                    for photo in photos! {
                        if let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
                            photoTemp = Photo(entity: entity, insertIntoManagedObjectContext: context)
                            photoTemp?.id = photo["id"] as? String
                            photoTemp?.url = photo["url_m"] as? String
                        }
//                        print(photoTemp?.url)
                    }
                }
                print("Getting new photos for dropped pin...")
                
                return handler(error: nil)
            })
        }
    }

    func getPhotosUsingCoordinates(lat: Double, long: Double, handler: (photos: [[String : AnyObject]]?, error: String?) -> Void) {
        
        let params = [
            "method": "flickr.photos.search",
            "api_key": myAPIKey,
            "bbox": bboxString(lat, long: long),
            "safe_search": "1",
            "extras": "url_m",
            "format": "json",
            "nojsoncallback": "1",
            "per_page": "30",
        ]
        
        let request = setupRequest("\(flickrAPI_URL)", params: params)
        
        getRequest(request) { (result, error) -> Void in
            
            guard error == nil else {
                handler(photos: nil, error: error)
                return
            }
            
            guard let data = result!["photos"] as? [String : AnyObject] else {
                print("No photos were found!")
                handler(photos: nil, error: "Data capture error")
                return
            }
            
            guard let photos = data["photo"] as? [[String: AnyObject]] else {
                print("No photos were found!")
                handler(photos: nil, error: "Data capture eror")
                return
            }
            
//            print(photos.count)
            
            handler(photos: photos, error: nil)
        }
    }
}