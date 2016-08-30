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
    
    // MARK:  - Properties
    var pins = [Pin]()
    var tappedPin: Pin? = nil

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
        
        // Map all persistant data
        mapSavedAnnotations()
    }
    
    // MARK: Helper Functions
    
    // Create fetch request
    func pinFetchRequest() -> [Pin] {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "long", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Get the saved pins
        do {
            return try context.executeFetchRequest(fetchRequest) as! [Pin]
        } catch {
            print("There was an error fetching the list of pins.")
            return [Pin]()
        }
    }
    
    // Map persistent data
    func mapSavedAnnotations() {
        
        pins = pinFetchRequest()
        
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    // Add new drop pin
    func addNewAnnotation(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .Began {
            let tapPoint = sender.locationInView(self.mapView)
            let mapCoordinate = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapCoordinate
            
            // add annotation to core data and store Lat / Long in core data
                if let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
                    let newPin = Pin(entity: entity, insertIntoManagedObjectContext: context)
                    newPin.lat = annotation.coordinate.latitude 
                    newPin.long = annotation.coordinate.longitude
                    pins.append(newPin)
                    
                    // Add photos to new pin
                    FlickrNetworkManager.sharedNetworkManager.addNewPhotos(newPin, handler: { _ in do {
                        try delegate.stack.saveContext()}
                    catch {
                        print("Error downloading initial photos.")
                        }
                    })
                }
            
            // Save data
            do {
                try delegate.stack.saveContext()
            } catch {
                print("Error saving pin data")
            }
            
            // set map point
            mapView.addAnnotation(annotation)
            
        }
    }
    
    // Function changes controller state
    override func setEditing(editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: false)
        
        // Show delete message view when editing button is tapped
        UIView.animateWithDuration(0.1) {
            self.mainView.frame.origin.y += self.deleteMessageView.frame.size.height * (editing ? -1 : 1)
        }
    }
    
    func viewPin(tappedPin: Pin) {
        
        let photoVC = storyboard!.instantiateViewControllerWithIdentifier("kPhotoCollectionController") as! PhotosCollectionViewController
        
        photoVC.pin = tappedPin
        navigationController!.pushViewController(photoVC, animated: true)
    }
    
    // Delete pins from core data
    func deletePins(tappedPin: MKAnnotation) {
        
        print("Deleting pin...")
        
        print(tappedPin.coordinate.latitude, tappedPin.coordinate.longitude)
        
        mapView.removeAnnotation(tappedPin)
        
        // Set context
        let managedObjContext = fetchedResultsController?.managedObjectContext
        
        // Set entity to reference
        let fetchPinsRequest = NSFetchRequest(entityName: "Pin")
        
        // Set rules for predicate (based on Latitude and longitude
        let fetchPredicate = NSPredicate(format: "lat contains %@ AND long contains %@", "\(tappedPin.coordinate.latitude)", "\(tappedPin.coordinate.longitude)")
        fetchPinsRequest.predicate = fetchPredicate
        fetchPinsRequest.returnsObjectsAsFaults = false
        
        let fetchedPins = try! managedObjContext?.executeFetchRequest(fetchPinsRequest) as? [Pin]
        
        // Remove pin from model
        for pinToDelete in fetchedPins! {
            managedObjContext?.deleteObject(pinToDelete)
        }
        
        do {
            try delegate.stack.saveContext()
        } catch {print("Failed to save after pin deletion.")}
    }
    
    // Delegate method for selection of existing annotation
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Got here TEST")
        let annotation = view.annotation
        tappedPin = nil
    
        for pin in pins {
            if annotation!.coordinate.latitude == pin.coordinate.latitude && annotation!.coordinate.longitude == pin.coordinate.longitude {
                tappedPin = pin
                editing ? deletePins(annotation!) : viewPin(tappedPin!)
            }
        }
    }
}
