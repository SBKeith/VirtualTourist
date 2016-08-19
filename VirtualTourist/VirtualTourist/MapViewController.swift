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
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    
    // MARK:  - Properties
    var pins = [Pin]()

    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
            fetchedResultsController?.delegate = self
        }
    }
    
    // Initializers
    init(fetchedResultsController fc : NSFetchedResultsController) {
        fetchedResultsController = fc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set bar button item title
        navigationItem.rightBarButtonItem = editButtonItem()
        
        // Set delegate
        mapView.delegate = self
        
        // Add gesture recognizer
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addNewAnnotation(_:)))
        longTouch.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longTouch)
        
        // Create a fetchrequest
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "long", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Get the saved pins
        do {
            if let results = try context.executeFetchRequest(fetchRequest) as? [Pin] {
                pins = results
            }
        } catch {
            fatalError("There was an error fetching the list of pins.")
        }
        
        // Map all persistant data
        mapSavedAnnotations()
    }
    
    
    // MARK: Helper Functions
    
    // Map persistent data
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
    
    // Add new drop pin
    func addNewAnnotation(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .Began {
            let tapPoint: CGPoint = sender.locationInView(mapView)
            let mapCoordinate = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
            var pin: Pin?
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = mapCoordinate
            
            // add annotation to core data and store Lat / Long in core data
            if pin == nil {
                if let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
                    pin = Pin(entity: entity, insertIntoManagedObjectContext: context)
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
    
    // Delete pins from core data
    func deletePins(tappedPin: MKAnnotation) {
        
        mapView.removeAnnotation(tappedPin)
        
        // Set context
        let managedObjContext = fetchedResultsController?.managedObjectContext
        
        // Set entity to reference
        let fetchPinsRequest = NSFetchRequest(entityName: "Pin")
        
        // Set rules for predicate (based on Latitude)
        let fetchPredicate = NSPredicate(format: "lat contains %@ AND long contains %@", "\(tappedPin.coordinate.latitude)", "\(tappedPin.coordinate.longitude)")
        fetchPinsRequest.predicate = fetchPredicate
        fetchPinsRequest.returnsObjectsAsFaults = false
        
        let fetchedPins = try! managedObjContext?.executeFetchRequest(fetchPinsRequest) as? [Pin]
        
        // Remove pin from model
        for pinToDelete in fetchedPins! {
            managedObjContext?.deleteObject(pinToDelete)
        }
        delegate.stack.autoSave(5)
    }
    
    func viewPin(tappedPin: MKAnnotation) {
        
        let photoVC = storyboard!.instantiateViewControllerWithIdentifier("kPhotoCollectionController") as! PhotosCollectionViewController
        
        photoVC.pin = tappedPin
        
        navigationController!.pushViewController(photoVC, animated: true)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: false)
        
        // Show delete message view when editing button is tapped
        UIView.animateWithDuration(0.1) { 
            self.mainView.frame.origin.y += self.deleteMessageView.frame.size.height * (editing ? -1 : 1)
        }
    }
    
    // Delegate method for selection of existing annotation
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        // Deselect pin; this allows it to be selected again if it's not deleted
        mapView.deselectAnnotation(view.annotation!, animated: false)
        
        // Remove pin from model
        if let tappedPin = view.annotation {
            editing ? deletePins(tappedPin) : viewPin(tappedPin)
        }
    }
}
