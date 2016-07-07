//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 7/2/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    

    @IBOutlet weak var mapView: MKMapView!
    
    // MARK:  - Properties
    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController,
                                  style : MKMapView){
        fetchedResultsController = fc
        super.init(style: style)
    }
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Set the title
//        title = "CoolNotes"
//        
//        // Get the stack
//        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let stack = delegate.stack
//        
//        // Create a fetchrequest
//        let fr = NSFetchRequest(entityName: "Notebook")
//        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
//                              NSSortDescriptor(key: "creationDate", ascending: false)]
//        
//        // Create the FetchedResultsController
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
//                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
//        
//        
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchRequest
        let fr = NSFetchRequest(entityName: "Pin")
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotation(_:)))
        longTouch.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longTouch)
    }
    
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
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
