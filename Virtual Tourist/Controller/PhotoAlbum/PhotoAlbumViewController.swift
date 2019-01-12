//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Komil Bagshi on 05/01/2019.
//  Copyright © 2019 KamelBaqshi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController  {
    
    
    
    //long lat values
    var latitude : Double?
    var longitude : Double?
    //IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var toolbarButton: UIBarButtonItem!
    
    //CoreData
    
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    var selectedPhotos: [IndexPath]! = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //delegates
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        //view
        collectionView.allowsMultipleSelection = true
        setDelegateAndDataSource()
        //map
        createAnnotation()
        //fetch
        setupFetchedResultsController()
        if fetchedResultsController.fetchedObjects!.count == 0 {
            print("loading")
            loadPhotos()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    
    
    func setDelegateAndDataSource() {
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func createAnnotation(){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
        mapView.addAnnotation(annotation)
        
        //zooming to location
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        
        self.mapView.isZoomEnabled = false;
        self.mapView.isScrollEnabled = false;
        self.mapView.isUserInteractionEnabled = false;
        
        mapView.setRegion(region, animated: true)
        
        
    }
    
    
    func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    
    
    
    func loadPhotos() {
        
        let flickrCall = FlickrApi.sharedInstance
        
        flickrCall.getPhotosforLocation(latitude!, longitude!, 20) { (success, photos) in
            
            if success == false {
                print("Unable to download images from Flickr.")
                return
            }
            
            print("Flickr images fetched : \(photos!.count)")
            if photos!.count == 0 {
                
                displayAlert.displayAlert(message: "This location contains no images.", title: "whops..", vc: self)
            }
            
            photos!.forEach() { photo_url in
                let photo = Photos(context: self.dataController.viewContext)
                photo.photoURL = URL(string: photo_url["url_m"] as! String)?.absoluteString
                photo.pin = self.pin
                
                do {
                    // Saves to CoreData
                    try self.dataController.viewContext.save()
                } catch  {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    // MARK: Download Images
    
    func downloadImage( imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void){
        
        // Create session and request
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        // Create network request
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                
                completionHandler(data, nil)
            }
        }
        task.resume()
    }
    
    
    // MARK: Refresh New Collection
    
    
    @IBAction func updateCollection(_ sender: Any) {
        if hasSelectedPhotos() {
            deleteSelectedPhotos()
        } else {
            fetchedResultsController.fetchedObjects?.forEach() { photo in
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    print("Unable to delete photo. \(error.localizedDescription)")
                }
            }
            loadPhotos()
            self.collectionView.reloadData()
        }
    }
    
} // end of class


