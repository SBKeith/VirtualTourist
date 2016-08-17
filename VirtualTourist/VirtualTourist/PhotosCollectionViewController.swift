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
    var photosArray = [Photo]()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    var photoURLs = [UIImage]?()
    var pin: MKAnnotation? = nil
    
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
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSizeMake(120, 120)
        self.collectionView.setCollectionViewLayout(layout, animated: true)
        
        setupCollectionFlowLayout()
        
        // Create a fetchrequest
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true), NSSortDescriptor(key: "url", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Get the saved photos from core data
        do {
            if let results = try context.executeFetchRequest(fetchRequest) as? [Photo] {
                photosArray = results
            }
        } catch {
            fatalError("There was an error fetching the list of pins.")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
            // MOVE TO PHOTO.SWIFT - for testing purposes only!
            FlickrNetworkManager.sharedNetworkManager.getPhotosUsingCoordinates((pin?.coordinate.latitude)!, long: (pin?.coordinate.longitude)!) { (photos, error) -> Void in
                
//                self.addNewPhotoAlbum(photos!)
                
                var photoTemp: Photo?
                
                for photo in photos! {
                    if photoTemp == nil {
                        if let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
                            photoTemp = Photo(entity: entity, insertIntoManagedObjectContext: context)
                            photoTemp?.id = photo["id"] as? String
                            photoTemp?.url = photo["url_m"] as? String
                        }
                        print(photoTemp, "\n")
                    }
                }
                delegate.stack.autoSave(5)
        }
    }
    
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
    
    // Load photos from URLs
    func loadPhoto(handler: (image: UIImage?, error: String) -> Void) {
        
        if photosArray.count > 0 {
            for photoInfo in 0 ... (photosArray.count - 1) {
                if photosArray[photoInfo].url != nil {
                task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: photosArray[photoInfo].url!)!)) { data, response, downloadError in
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
            }
        }
    }

    
    // Dismiss collection view controller
    func dismissCollectionVC() {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
        
//        return self.fetchedResultsController.sections?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        print("got here 1")
        
//        return photos.count ?? 0
        return 5
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        print("got here 2")

        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        loadPhoto() { (image, error) in
        
            cell.photoImageView.image = image
        }
        
        return cell
    }
}