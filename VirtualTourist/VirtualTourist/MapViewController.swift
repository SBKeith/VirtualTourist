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
        
        if sender.state == .Began {
            print("Got here")
        }
    }
}
