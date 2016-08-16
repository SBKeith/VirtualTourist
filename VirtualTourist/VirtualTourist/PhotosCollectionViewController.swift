//
//  PhotosCollectionViewController.swift
//  VirtualTourist
//
//  Created by Keith Kowalski on 8/8/16.
//  Copyright © 2016 TouchTapApp. All rights reserved.
//

import UIKit
import MapKit
import CoreData

private let reuseIdentifier = "Cell"

class PhotosCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var task: NSURLSessionTask? = nil
    var photos = [Photo]()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", argumentArray: self.pin! as? [AnyObject])
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    
//    var fetchedResultsController : NSFetchedResultsController?{
//        didSet{
//            fetchedResultsController?.delegate = self
//        }
//    }
    
    
//    // Initializers
//    init(fetchedResultsController fc : NSFetchedResultsController) {
//        fetchedResultsController = fc
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }

    
    var photoURLs = [UIImage]?()
    var pin: MKAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set left bar button item properties
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "OK", style: .Plain, target: self, action: #selector(dismissCollectionVC))
        
        // Set pin from selected annotation; adjust map positioning
        mapView.addAnnotation(pin!)
        mapView.setRegion(MKCoordinateRegion(center: pin!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        
        // Set delegaet and dataSource
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSizeMake(120, 120)
        self.collectionView.setCollectionViewLayout(layout, animated: true)
        
        
        // Create a fetchrequest
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true), NSSortDescriptor(key: "url", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Get the saved photos
        do {
            if let results = try context.executeFetchRequest(fetchRequest) as? [Photo] {
                photos = results
            }
        } catch {
            fatalError("There was an error fetching the list of pins.")
        }
    
        print(photos.count) // Count found here at least...
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // MOVE TO PHOTO.SWIFT - for testing purposes only!
        FlickrNetworkManager.sharedNetworkManager.getPhotosUsingCoordinates(44.5192, long: -88.0198, page: 1) { (photos, pages, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                for photo in photos! where photo["url_m"] != nil {
                    _ = Photo(photoDictionary: photo, context: context)
                }
            })
            delegate.stack.autoSave(5)
        }

    }
    
    func loadPhoto(url: String, handler: (image: UIImage?, error: String) -> Void) {
        task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: url)!)) { data, response, downloadError in
            dispatch_async(dispatch_get_main_queue(), {
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("Photo not loaded")
                    return handler(image: nil, error: "Photo not loaded")
                }
                
                return handler(image: image, error: "")
            })
            
        }
        task!.resume()
    }

    
    // Dismiss collection view controller
    func dismissCollectionVC() {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return self.fetchedResultsController.sections?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("got here")

        return fetchedResultsController.sections![section].numberOfObjects
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        print("got here")

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        loadPhoto(photo.url!) { (image, error) in
            
            cell.photoImageView.image = image
        }
        
        // Configure the cell
    
        return cell
    }
}