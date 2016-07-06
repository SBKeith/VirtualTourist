//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 7/2/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotation(_:)))
        longTouch.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longTouch)
    }
    
    func addAnnotation(sender: UILongPressGestureRecognizer) {
        
        let tapPoint: CGPoint = sender.locationInView(mapView)
        let mapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
        if sender.state == .Began {
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapCoordinate
            
            // add annotation to core data
                // Store Lat / Long in core data
            
            mapView.addAnnotation(annotation)
            
        }
    }
}






//            // Delete any existing annotations.
//            if mapView.annotations.count != 0 {
//                mapView.removeAnnotations(mapView.annotations)
