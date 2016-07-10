//
//  NotebooksViewController.swift
//  CoolNotes
//
//  Created by Fernando Rodríguez Romero on 10/03/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import UIKit
import CoreData
import MapKit

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
    
    init(fetchedResultsController fc : NSFetchedResultsController) {
        fetchedResultsController = fc
        super.init(nibName: nil, bundle: nil)
    }
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true),
                              NSSortDescriptor(key: "long", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    
        addSavedAnnotations()
        
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addNewAnnotation(_:)))
        longTouch.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longTouch)
    }
    
    func addSavedAnnotations() {
        
        let pin = fetchedResultsController?.fetchedObjects
        
        print(pin!)
    }
    
    func addNewAnnotation(sender: UILongPressGestureRecognizer) {
        
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

// MARK:  - Fetches
extension MapViewController {
    
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}






//            // Delete any existing annotations.
//            if mapView.annotations.count != 0 {
//                mapView.removeAnnotations(mapView.annotations)
