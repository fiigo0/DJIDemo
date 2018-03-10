//
//  FBManager.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 2/21/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import Foundation
import FirebaseDatabase


class FBManager: NSObject {
    
    static let sharedInstance:FBManager = FBManager()
    private var ref: DatabaseReference = Database.database().reference()
    
    func addLog(message:String){
        self.ref.child("Logs").child(message).setValue(0)
    }
    func log(method:String, withMessage message:String) {
        self.ref.child("Logs").child(method).setValue(message)
    }
    
    func updateDroneLocation(location:String) {
        self.ref.child("DroneData").child("coordinates").setValue(location);
    }
    
    func addWaypointEntry(index:Int, coordenate:String)  {
           self.ref.child("DroneMissionData").child("waypoints").child("\(index)").setValue(coordenate);
    }
    func clearWaypoints()  {
        self.ref.child("DroneMissionData").child("waypoints").removeValue();
    }
    
    func updateDroneData(node:String, value:String) {
        self.ref.child("DroneData").child(node).setValue(value);
    }
    
    func resetLogs(){
        self.ref.child("Logs").removeValue()
//        self.ref.child("Logs").child("appRegisteredWithError").setValue(" ")
//        self.ref.child("Logs").child("fetchFlightController").setValue(" ")
//        self.ref.child("Logs").child("flightController").setValue(" ")
//        self.ref.child("Logs").child("focusButtonPressed").setValue(" ")
//        self.ref.child("Logs").child("productConnected").setValue(" ")
//        self.ref.child("Logs").child("productConnected_FC_Instanciated").setValue(" ")
//        self.ref.child("Logs").child("productDisconnected").setValue(" ")
//        self.ref.child("Logs").child("startUpdateLocation").setValue(" ")
//        self.ref.child("Logs").child("updateAircraftLocation").setValue(" ")
//        self.ref.child("Logs").child("updateAircraftLocation_location").setValue(" ")
//        self.ref.child("Logs").child("updateUI_appState").setValue(" ")
//        self.ref.child("Logs").child("updateUI_bindState").setValue(" ")
//        self.ref.child("Logs").child("startUpdateLocation").setValue(" ")
//        self.ref.child("Logs").child("startUpdateLocation_locationManager").setValue(" ")
//        self.ref.child("Logs").child("mapView_viewForAnnotation").setValue(" ")
//        self.ref.child("Logs").child("mapView_viewForAnnotation_title").setValue(" ")
//        self.ref.child("Logs").child("flightController_droneLocation").setValue(" ")
//        self.ref.child("Logs").child("flightController_droneLocation_yaw").setValue(" ")
    }
    
    
    func getOrders(completionHandler:@escaping ([Order]) -> ()){
        self.ref.child("purchaseOrders").observe(DataEventType.value) { (snapshot) in
            var ordersArray:[Order] = []
            let data = snapshot.value as? NSDictionary
            
            for item in data! {
                let values = item.value as! [String:Any]
                let ord = Order()
                ord.name = values["itemName"] as? String ?? " "                
                ord.status = values["status"] as? String ?? " "

                ordersArray.append(ord)
            }
            
            completionHandler(ordersArray)
        }
    }
}

