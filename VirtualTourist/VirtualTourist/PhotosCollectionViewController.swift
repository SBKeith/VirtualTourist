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
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
    
    // Set variables
    var pin: Pin? = nil
    var photosArray = [Photo]()
    var indexToRemove = [IndexPath]()
    
    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lowerButton: UIButton!
    
    // MARK: - Loading methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set left bar button item properties
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(dismissCollectionVC))
        
        // Set pin from selected annotation; adjust map positioning
        mapView.addAnnotation(pin!)
        mapView.setRegion(MKCoordinateRegion(center: pin!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        
        // Set delegate and dataSource
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Setup collection view cell layout
        setupCollectionFlowLayout()
        
        collectionView.backgroundColor = UIColor.gray
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        layout.itemSize = CGSize(width: dimension, height: dimension)
        
        collectionView.collectionViewLayout = layout
    }
    
    func photosFetchRequest() -> [Photo] {
        
        print("Fetching Photos...")
        
        // Get the saved Photos
        do {
            return try context.fetch(fetchRequest) as! [Photo]
        } catch {
            print("There was an error fetching the list of pins.")
            return [Photo]()
        }
    }

    // Dismiss collection view controller
    func dismissCollectionVC() {
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photosArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
    
        // Cleanup reused cell
        DispatchQueue.main.async {
            cell.photoImageView.image = nil
        }
        
        // Check if saved data exists in coredata
        if let imageData = self.photosArray[indexPath.item].imageData {
            print("Loading new photo from coredata")
            DispatchQueue.main.async {
                if let image = UIImage(data: imageData as Data) {
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
                DispatchQueue.main.async {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        
        if indexToRemove.contains(indexPath) {
            indexToRemove.remove(at: indexToRemove.index(of: indexPath)!)
            cell.alpha = 1.0
            if indexToRemove.count == 0 {
                lowerButton.setTitle("New Collection", for: UIControlState())
                lowerButton.tag = 0
            }
        } else {
            if indexToRemove.count == 0 {
                lowerButton.setTitle("Remove selected images", for: UIControlState())
                lowerButton.tag = 1
            }
            indexToRemove.append(indexPath)
            
            cell.alpha = 0.5
        }
    }
    
    func deleteSelectedPhotos() {
        
        var photosToDelete = [Photo]()
        
        print(indexToRemove.count)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        request.predicate = NSPredicate(format: "pin == %@", self.pin!)
        
        do {
            var photos = try context.fetch(request) as! [Photo]
            for indexPath in indexToRemove {
                
                print("IndexPath: ", indexPath.row)
                print("Photos: ", photos.count)
                
                let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
                photosToDelete.append(photos.remove(at: indexPath.row))
                
                print("Photos to delete: ", photosToDelete)
                
                cell.photoImageView.image = nil
                
                photosArray.remove(at: indexPath.row)
            }
            for photos in photosToDelete {
                context.delete(photos)
            }
        } catch {}
        
        do { try delegate.stack.saveContext() } catch {
            print("Error saving deleted photos")
        }
    }
    
    // Delete All photos in coredata (via selected pin)
    func deleteAllPhotos() {
        
        print("Deleting photos imageData...")

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        
        request.predicate = NSPredicate(format: "pin == %@", self.pin!)
        
        do {
            let photos = try context.fetch(request) as! [Photo]
            for photo in photos {
                context.delete(photo)
            }
        } catch { print("Error deleting photo") }
        
        photosArray.removeAll()
    
        do { try delegate.stack.saveContext() } catch {
            print("Error saving deletion")
        }
    }

    // Rename to 'lowerButton'
    @IBAction func lowerButtontapped(_ sender: UIButton) {
        
        switch (sender.tag) {
        case 0:
            var photoTemp: Photo?
            
            deleteAllPhotos()
            
            FlickrNetworkManager.sharedNetworkManager.getPhotosUsingCoordinates(pin!.lat, long: pin!.long, page: FlickrNetworkManager.sharedNetworkManager.randomPage) { (photos, error) in
                
                DispatchQueue.main.async {
                    
                    for photo in photos! {
                        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
                            photoTemp = Photo(entity: entity, insertInto: context)
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
        case 1:
            DispatchQueue.main.async(execute: { 
                self.deleteSelectedPhotos()
                self.photosArray = self.photosFetchRequest()
                self.collectionView.deleteItems(at: self.indexToRemove)
                self.indexToRemove.removeAll()
                self.lowerButton.setTitle("New Collection", for: UIControlState())
                self.lowerButton.tag = 0
            })
        default: break
        }
    }
}
