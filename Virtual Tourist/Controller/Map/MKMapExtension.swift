//
//  MKMapExtension.swift
//  Virtual Tourist
//
//  Created by Komil Bagshi on 09/01/2019.
//  Copyright © 2019 KamelBaqshi. All rights reserved.
//

import Foundation
import MapKit

// MARK: Extension for MKMapViewDelegate

extension TravelLocationMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView!.pinTintColor = UIColor.red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("tapped on pin")
        //assign lat and log
        if let latitude = view.annotation?.coordinate.latitude , let longitude = view.annotation?.coordinate.longitude {
            //assign values to be sent through segue
            self.longitude = longitude
            self.latitude = latitude
            
            let newPin = Pin(context: dataController.viewContext)
            newPin.latitude = longitude
            newPin.longitute = latitude
            self.myPin = newPin
            
            self.performSegue(withIdentifier: "photoAlbumSegue", sender: nil)
        }
    }
    
} // end of extension

