//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 7/10/2016
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var managedObjectContext: NSManagedObjectContext!
    var pin = [Pin]()
    var annotations = [MKAnnotation]()
    
    // MARK:  - Properties
    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
            fetchedResultsController?.delegate = self
            executeSearch()
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController) {
        fetchedResultsController = fc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do {
            if let results = try stack.context.executeFetchRequest(fetchRequest) as? [Pin] {
                pin = results
            }
        } catch {
            fatalError("There was an error fetching the list of pins.")
        }
    
        // Map all persistant data
        mapSavedAnnotations()
        
        // Add gesture recognizer
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addNewAnnotation(_:)))
        longTouch.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longTouch)
    }
    
    
    // MARK: Helper Functions
    func mapSavedAnnotations() {
        
        for dropPin in 0 ... (pin.count - 1) {
            let annotation = MKPointAnnotation()
            let pointLocation: CLLocationCoordinate2D
            
            pointLocation = pin[dropPin].coordinates
            annotation.coordinate = pointLocation
            
            mapView.addAnnotation(annotation)
        }
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
