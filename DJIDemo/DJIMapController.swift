//
//  DJIMapController.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 2/19/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit
import MapKit

class DJIMapController: NSObject, MKMapViewDelegate {
    
    static let sharedInstance = DJIMapController()
    
    var editPoints:[CLLocation] = []

    var wayPoints:[CLLocation] = []
    
    /**
     *  Add Waypoints in Map View
     */
    func addPoint(point:CGPoint, withMapView mapView:MKMapView){
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        let location = CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        editPoints.append(location)
        
        let annotation = MKPointAnnotation()
        annotation.title = "x"
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
    }
    
    /**
     *  Clean All Waypoints in Map View
     */
    
    func cleanAllPointsWithMapView(mapView:MKMapView){
        editPoints.removeAll()
        let annos = mapView.annotations
        mapView.removeAnnotations(annos)
    }
    
    
    
}
