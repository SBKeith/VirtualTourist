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
    
    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    // Set variables
    var task: NSURLSessionTask? = nil
    var photosArray = [Photo]()
    var pin: MKAnnotation? = nil
    var loading = false
    var photo: Photo?
    
    // Fetch request
    let fetchRequest = NSFetchRequest(entityName: "Photo")
    
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
        
        // Set fetch request sort descriptors
        // Create a fetchrequest
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true), NSSortDescriptor(key: "url", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Setup collection view cell layout
        setupCollectionFlowLayout()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            if let results = try context.executeFetchRequest(fetchRequest) as? [Photo] {
                photosArray = results
            }
        } catch {
            fatalError("There was an error fetching the list of pins.")
        }
        
//        if photosArray.count == 0 {
//            print("addNewPhotos")
//            photo!.addNewPhotos(context, handler: { _ in
//                print("Got here")
////                delegate.stack.autoSave(5)
//            })
//        }

    }
    
    // Load photos from URLs
    func loadPhoto(indexPath: NSIndexPath, handler: (image: UIImage?, error: String) -> Void) {
        
        if photosArray.count > 0 {
            if photosArray[indexPath.item].url != nil {
            task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: photosArray[indexPath.item].url!)!)) { data, response, downloadError in
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
    
    // Dismiss collection view controller
    func dismissCollectionVC() {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print(photosArray.count < 5 ? photosArray.count : 5)
        return photosArray.count < 5 ? photosArray.count : 5    // Change this to match max of 30 or less
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        if indexPath.item < photosArray.count {
            loadPhoto(indexPath) { (image, error) in
            
                cell.photoImageView.image = image
            }
        }
        return cell
    }
}