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
    
    var aircraftAnnotation:DJIAircraftAnnotation?
    
    var editPoints:[CLLocation] = []

    var wayPoints:[CLLocation] {
        get {
            return self.editPoints
        }
    }
    
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
        
        for an in annos {
            if !(an.isEqual(self.aircraftAnnotation)){
                mapView.removeAnnotation(an)
            }
        }
    }
    
    /**
     *  Update Aircraft's location in Map View
     */
    
    func updateAircraftLocation(location:CLLocationCoordinate2D, withMapView mapView:MKMapView) {
        if self.aircraftAnnotation == nil {
            self.aircraftAnnotation = DJIAircraftAnnotation(coordinate: location)
            mapView.addAnnotation(self.aircraftAnnotation!)
        }else {
        }
        
        self.aircraftAnnotation?.setCoordinate(coordinate: location)
    }
    
    /**
     *  Update Aircraft's heading in Map View
     */
    
    func updateAircraftHeading(heading:Float) {
        if (self.aircraftAnnotation != nil) {
            self.aircraftAnnotation?.updateHeading(heading: heading)
        }
    }
    
    func addLog(method:String,message:String) {
        FBManager.sharedInstance.log(method: method, withMessage: message)
    }
    
    
    
    
}
