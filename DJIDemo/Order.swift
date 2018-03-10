//
//  Order.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 3/3/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import Foundation
import CoreLocation

class Order: NSObject {
    var name:String!
    var status:String!
    var coordinate:CLLocation!

    override init() {
        super.init()
        self.name = ""
        self.status = ""
        self.coordinate = CLLocation(latitude: 25.670012, longitude: -100.377818)
    }
}
