//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 7/10/2016
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var deleteMessageView: UIView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // Get the stack
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var pins = [Pin]()
    
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
        
        // Set delegate
        mapView.delegate = self
        
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
                //                print("Preloaded data: \n\(pins)\n\n")
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
        if pins.count > 0 {
            for dropPin in 0 ... (pins.count - 1) {
                let annotation = MKPointAnnotation()
                let pointLocation: CLLocationCoordinate2D
                
                pointLocation = pins[dropPin].coordinate
                annotation.coordinate = pointLocation
                
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func addNewAnnotation(sender: UILongPressGestureRecognizer) {
        
        let tapPoint: CGPoint = sender.locationInView(mapView)
        let mapCoordinate = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
        var pin: Pin?
        
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
        
        switch sender.tag {
            
        case 0:
            UIView.animateWithDuration(0.1) {
                
                self.mainView.frame.origin.y -= self.deleteMessageView.frame.size.height
                
                let updatedEditButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.editButtonTapped(_:)))
                updatedEditButton.tag = 1
                self.navigationItem.rightBarButtonItem = updatedEditButton
            }
        case 1:
            UIView.animateWithDuration(0.1, animations: {
                
                self.mainView.frame.origin.y += self.deleteMessageView.frame.size.height
                
                let updatedEditButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(self.editButtonTapped(_:)))
                updatedEditButton.tag = 0
                self.navigationItem.rightBarButtonItem = updatedEditButton
            })
        default: break
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        // TODO: Set check for 'edit' bar button item status (dictate delete vs change view controller)
        
        // Set context
        let context = fetchedResultsController?.managedObjectContext
        
        // Set entity to reference
        let fetchPinsRequest = NSFetchRequest(entityName: "Pin")
        
        // Set rules for predicate (based on Latitude)
        let fetchPredicate = NSPredicate(format: "lat contains %@ AND long contains %@", "\(view.annotation!.coordinate.latitude)", "\(view.annotation!.coordinate.longitude)")
        fetchPinsRequest.predicate = fetchPredicate
        fetchPinsRequest.returnsObjectsAsFaults = false
        
        let fetchedPins = try! context?.executeFetchRequest(fetchPinsRequest) as? [Pin]
        
        // Remove pin from map
        mapView.removeAnnotation(view.annotation!)
        
        // Remove pin in core data
        for pinToDelete in fetchedPins! {            
            context?.deleteObject(pinToDelete)
        }
        delegate.stack.autoSave(5)
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
