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

class PhotosCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var photoURLs = [NSURL]?()
    
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
        
        // MOVE TO PHOTO.SWIFT - for testing purposes only!
        FlickrNetworkManager.sharedNetworkManager.getPhotosUsingCoordinates(44.5192, long: -88.0198, page: 1) { (photos, pages, error) -> Void in
//
//
            
            
                for photo in photos! where photo["url_m"] != nil {
                    print(photo["url_m"]!)
                    
                    self.photoURLs?.append(photo["url_m"] as! NSURL)
                    
                }
            
//
//                    if let url = NSURL(string: photo["url_m"] as! String) {
//                        if let data = NSData(contentsOfURL: url) {
//                            self.photoTemp.photoImageView.image = UIImage(data: data)
//                        }
//                    }
////                    let newImage = UIImage(data: NSData(contentsOfURL: NSURL(string: photo["url_m"] as! String)!)!)
////                    self.photoTemp.photoImageView.image = newImage
//                }
        }
        
        print(self.photoURLs?.count)

    }
    
    func getURL(photoURL: NSURL) {
     
        
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
        // #warning Incomplete implementation, return the number of items
        return 30
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        
    
        // Configure the cell
    
        return cell
    }
    
    // Collection view layout
//    func setupCollectionFlowLayout() {
//        let items: CGFloat = view.frame.size.width > view.frame.size.height ? 5.0 : 3.0
//        let space: CGFloat = 3.0
//        let dimension = (view.frame.size.width - ((items + 1) * space)) / items
//        
//        let layout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layout.minimumLineSpacing = 8.0 - items
//        layout.minimumInteritemSpacing = space
//        layout.itemSize = CGSizeMake(dimension, dimension)
//        
//        collectionView.collectionViewLayout = layout
//    }
}