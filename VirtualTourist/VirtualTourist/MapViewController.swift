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
    @IBOutlet weak var tapToDeleteView: UIView!
    
    // Get the stack
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var pins = [Pin]()
    var pin: Pin?
    
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
        
        // Add gesture recognizer
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addNewAnnotation(_:)))
        longTouch.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longTouch)
        
        // Create a fetchrequest
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "long", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            if let results = try delegate.stack.context.executeFetchRequest(fetchRequest) as? [Pin] {
                pins = results
                print("Preloaded data: \n\(pins)\n\n")
            }
        } catch {
            fatalError("There was an error fetching the list of pins.")
        }
        // Map all persistant data
        mapSavedAnnotations()
    }
    
    
    // MARK: Helper Functions
    
    // Map persistent data (currently just preloaded data from AppDelegate)
    func mapSavedAnnotations() {
        
        for dropPin in 0 ... (pins.count - 1) {
            let annotation = MKPointAnnotation()
            let pointLocation: CLLocationCoordinate2D
            
            pointLocation = pins[dropPin].coordinates
            annotation.coordinate = pointLocation
            
            mapView.addAnnotation(annotation)
        }
    }
    
    func addNewAnnotation(sender: UILongPressGestureRecognizer) {
        
        let tapPoint: CGPoint = sender.locationInView(mapView)
        let mapCoordinate = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
        if sender.state == .Began {
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapCoordinate
            
            // add annotation to core data and store Lat / Long in core data
            if pin == nil {
                if let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: delegate.stack.context) {
                    pin = Pin(entity: entity, insertIntoManagedObjectContext: delegate.stack.context)
                    pin?.lat = mapCoordinate.latitude
                    pin?.long = mapCoordinate.longitude
                }
            }
            
            // Save data
            delegate.stack.autoSave(5)
            
            // set map point
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        
        
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
