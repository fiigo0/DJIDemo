//
//  WaypointViewController.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 2/16/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit
import DJISDK

class WaypointViewController: UIViewController, DJISDKManagerDelegate, DJIAppActivationManagerDelegate, MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager:CLLocationManager?
    var userLocation:CLLocationCoordinate2D?
    let mapController = DJIMapController()
    
    var activationState:DJIAppActivationState!
    var aircraftBindingState:DJIAppActivationAircraftBindingState!
    var editPoints:[CLLocation] = [];
    
    var tapGestureRecog:UITapGestureRecognizer?
    var isEditingPoints:Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerApp()
        
        mapView.delegate = self
        mapView?.showsUserLocation = true
        
        self.userLocation = kCLLocationCoordinate2DInvalid
        
        //
//        self.requestLocationAccess()
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager.distanceFilter = 0.1;
        //
        tapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(self.addWaypoints(_:)))
        tapGestureRecog?.numberOfTapsRequired = 1
        tapGestureRecog?.numberOfTouchesRequired = 1
        self.mapView.addGestureRecognizer(self.tapGestureRecog!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startUpdateLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager?.stopUpdatingLocation()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func startUpdateLocation() {
        
        if CLLocationManager.locationServicesEnabled(){
            if self.locationManager == nil {
                self.locationManager = CLLocationManager()
                self.locationManager?.delegate = self
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager?.distanceFilter = 0.1
                self.locationManager?.requestAlwaysAuthorization()
                self.locationManager?.startUpdatingLocation()
            }else {
                let alertController = UIAlertController(title: nil, message: "Takes the appearance of the bottom bar if specified; otherwise, same as UIActionSheetStyleDefault.", preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                
                }
                alertController.addAction(cancelAction)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                
                }
                alertController.addAction(OKAction)
                
                
                self.present(alertController, animated: true) {
                    
                }
            }
        }
        
        
    }
    
    @objc func addWaypoints(_ tapGesture:UITapGestureRecognizer) {
        
        let point = tapGestureRecog?.location(in: self.mapView)
        
        if tapGesture.state == UIGestureRecognizerState.ended {
            if self.isEditingPoints {
                self.mapController.addPoint(point: point!, withMapView: self.mapView)
            }
        }
    }
    

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKPointAnnotation.self) {
            let pinView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "PinAnnotation")
            pinView.pinTintColor = UIColor.purple
            return pinView
        }
        return nil
    }
    
    func registerApp(){
        DJISDKManager.registerApp(with: self)
    }

    func appRegisteredWithError(_ error: Error?) {
        var message = "Register app Successed!"
        
        if error != nil {
            print(error.debugDescription)
            message = "Register App Failed! Please enter your App Key in the plist file and check the network.";
        } else {
            print("RegisterAppSuccess")
            DJISDKManager.startConnectionToProduct()
            DJISDKManager.appActivationManager().delegate = self
            self.activationState = DJISDKManager.appActivationManager().appActivationState
            self.aircraftBindingState = DJISDKManager.appActivationManager().aircraftBindingState
        }
        print(message)
    }
    
    // MARK: DJIAppActivationManagerDelegate Methods
    
    func manager(_ manager: DJIAppActivationManager!, didUpdate appActivationState: DJIAppActivationState) {
        self.activationState = appActivationState
        
    }
    
    func manager(_ manager: DJIAppActivationManager!, didUpdate aircraftBindingState: DJIAppActivationAircraftBindingState) {
        self.aircraftBindingState = aircraftBindingState
        
    }
    
    // DJISDKManagerDelegate Methods
    func productConnected(_ product: DJIBaseProduct?) {
        NSLog("Product Connected")
    }
    
    func productDisconnected() {
        NSLog("Product Disconnected")
    }
    
    func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
            
        case .denied, .restricted:
            print("location access denied")
            
        default:
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func editButton(_ sender: UIButton) {
        if (self.isEditingPoints) {
            self.mapController.cleanAllPointsWithMapView(mapView: self.mapView)
            self.editBtn .setTitle("Edit", for: UIControlState.normal)
            
        }else
        {
            self.editBtn.setTitle("Reset", for: UIControlState.normal)
        }
        
        self.isEditingPoints = !self.isEditingPoints;
    }
    
    @IBAction func focusMapAction(_ sender: UIButton) {
        if CLLocationCoordinate2DIsValid(self.userLocation!){
            let span = MKCoordinateSpanMake(0.001, 0.001)
            let region = MKCoordinateRegion(center: self.userLocation!, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.userLocation = location?.coordinate
    }
    
    
}
