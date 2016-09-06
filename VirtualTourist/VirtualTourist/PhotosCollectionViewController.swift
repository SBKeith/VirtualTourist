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

    // MARK: -Properties
    let flickrManager = FlickrNetworkManager()
    let fetchRequest = NSFetchRequest(entityName: "Photo")
    
    // Set variables
    var pin: Pin? = nil
    var photosArray = [Photo]()
    
    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lowerButton: UIButton!
    
    // MARK: - Loading methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set left bar button item properties
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "OK", style: .Plain, target: self, action: #selector(dismissCollectionVC))
        
        // Set pin from selected annotation; adjust map positioning
        mapView.addAnnotation(pin!)
        mapView.setRegion(MKCoordinateRegion(center: pin!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        
        // Set delegate and dataSource
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Setup collection view cell layout
        setupCollectionFlowLayout()
        
        collectionView.backgroundColor = UIColor.grayColor()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        photosArray = photosFetchRequest()
    }
    
    // Collection view cell layout logic (adjusts for portrait vs landscape)
    func setupCollectionFlowLayout() {
        let items: CGFloat = view.frame.size.width > view.frame.size.height ? 5.0 : 3.0
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - ((items + 1) * space)) / items
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 8.0 - items
        layout.minimumInteritemSpacing = space
        layout.itemSize = CGSizeMake(dimension, dimension)
        
        collectionView.collectionViewLayout = layout
    }
    
    func photosFetchRequest() -> [Photo] {
        
        print("Fetching Photos...")
        
        // Get the saved Photos
        do {
            return try context.executeFetchRequest(fetchRequest) as! [Photo]
        } catch {
            print("There was an error fetching the list of pins.")
            return [Photo]()
        }
    }

    // Dismiss collection view controller
    func dismissCollectionVC() {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photosArray.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
    
        // Cleanup reused cell
        dispatch_async(dispatch_get_main_queue()) {
            cell.photoImageView.image = nil
        }
        
        // Check if saved data exists in coredata
        if let imageData = self.photosArray[indexPath.item].imageData {
            print("Loading new photo from coredata")
            dispatch_async(dispatch_get_main_queue()) {
                if let image = UIImage(data: imageData) {
                    cell.photoImageView.image = image
                    // stop animating here
                    cell.activityIndicatorSpinner.stopAnimating()
                }
            }
        } else {
            print("Loading new photo from web URL link(s)")
            // start animating here
            cell.activityIndicatorSpinner.startAnimating()
            self.flickrManager.loadNewPhoto(indexPath, photosArray: self.photosArray) { (image, data, error) in
                guard error == "" else {
                    print(error)
                    return
                }
                dispatch_async(dispatch_get_main_queue()) {
                    cell.photoImageView.image = image
                    // stop animating here
                    cell.activityIndicatorSpinner.stopAnimating()
                }
                self.photosArray[indexPath.item].imageData = data
                
                // Save data
                do { try delegate.stack.saveContext() } catch {
                    print("Error saving photo data")
                }
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        lowerButton.setTitle("Remove selected images", forState: .Normal)
    }
    
    // HERE ----------
    func deletePhotos() {
        
        print("Deleting photos imageData...")

        let request = NSFetchRequest(entityName: "Photo")
        
        request.predicate = NSPredicate(format: "pin == %@", self.pin!)
        
        do {
            let photos = try context.executeFetchRequest(request) as! [Photo]
            for photo in photos {
                context.deleteObject(photo)
            }
        } catch {}
        
        photosArray.removeAll()
    
        do { try delegate.stack.saveContext() } catch {
            print("Error saving deletion")
        }
    }

    // Rename to 'lowerButton'
    @IBAction func lowerButtontapped(sender: UIButton) {
        
        var photoTemp: Photo?

        // Set a tag value to prevent interaction with wrong button (new collection / delete photos)
        deletePhotos()
        
        FlickrNetworkManager.sharedNetworkManager.getPhotosUsingCoordinates(pin!.lat, long: pin!.long, page: FlickrNetworkManager.sharedNetworkManager.randomPage) { (photos, error) in

            dispatch_async(dispatch_get_main_queue()) {
                
                for photo in photos! {
                    if let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
                        photoTemp = Photo(entity: entity, insertIntoManagedObjectContext: context)
                        photoTemp?.url = photo["url_m"] as? String
                        photoTemp?.pin = self.pin!
                    }
                }
                do { try delegate.stack.saveContext() } catch {
                    print("Error saving deletion")
                }
                
                print("RELOADING DATA...")
                self.photosArray = self.photosFetchRequest()
                self.collectionView.reloadData()
            }
        }
    }
}