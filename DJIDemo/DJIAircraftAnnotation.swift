//
//  DJIAircraftAnnotation.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 2/20/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit
import MapKit

class DJIAircraftAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var annotationView:DJIAircraftAnnotationView?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func setCoordinate(coordinate:CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
    
    func updateHeading(heading:Float){
        if self.annotationView != nil {
            self.annotationView?.updateHeading(heading: heading)
        }
    }
    

    
    
}
