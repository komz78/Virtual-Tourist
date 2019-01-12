//
//  TravelLocationMapViewController.swift
//  Virtual Tourist
//
//  Created by Komil Bagshi on 05/01/2019.
//  Copyright © 2019 KamelBaqshi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationMapViewController: UIViewController {
    
    //CoreData
    var dataController: DataController!
    
    //IBOutlets
    @IBOutlet var mapView: MKMapView!
    
    //log lat values
    var latitude : Double?
    var longitude : Double?
    var myPin: Pin?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupFetchedResultsController()
        // check long press and do an action through selector
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationMapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    // MARK: Handling Long Press
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        newAnnotation(Coordinate: touchMapCoordinate)
    }
    
    // MARK: After The Long Press Take Location Coordinate and Make New One
    
    func newAnnotation(Coordinate: CLLocationCoordinate2D ){
        let annotation = MKPointAnnotation()
        annotation.coordinate = Coordinate
        persistNewPin(location: Coordinate)
        mapView.addAnnotation(annotation)
    }
    
    // MARK: Function to Setup Save The Pin Data
    func persistNewPin(location: CLLocationCoordinate2D){
        let newPin = Pin(context: dataController.viewContext)
        newPin.latitude = location.latitude
        newPin.longitute = location.longitude
        do{
            try dataController.viewContext.save()
            print("saved view context")
        } catch{
            print("Persist New Pin Error")
        }
    }
    
    
    // MARK: Setup Fetched Results Controller
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            for pin in result {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitute))
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    // MARK: Prepare For Segue And Send Lon,Lat.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoAlbumSegue"{
            let vc = segue.destination as! PhotoAlbumViewController
            vc.latitude = self.latitude
            vc.longitude = self.longitude
            vc.pin = myPin
        }
    }
    
    
    
    
} // end of class

