//
//  MissionsViewController.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 2/21/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit
import DJISDK
import Fabric
import Crashlytics

class MissionsViewController: UIViewController, DJISDKManagerDelegate, DJIAppActivationManagerDelegate, MKMapViewDelegate,CLLocationManagerDelegate,DJIFlightControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editBtn: UIButton!
    
    //Objects
    var mapController:DJIMapController = DJIMapController()
    
    //Location
    var locationManager:CLLocationManager?
    var userLocation:CLLocationCoordinate2D?
    var droneLocation:CLLocationCoordinate2D?
    
    var activationState:DJIAppActivationState = DJIAppActivationState.unknown
    var aircraftBindingState:DJIAppActivationAircraftBindingState = DJIAppActivationAircraftBindingState.unknown
    var editPoints:[CLLocation] = []
    var tapGestureRecog:UITapGestureRecognizer?
    var isEditingPoints:Bool = false
    override var prefersStatusBarHidden: Bool {
        return false
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerApp()
        self.updateUI()
        self.initData()
        self.updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startUpdateLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager?.stopUpdatingLocation()
    }
    
    func registerApp(){
        DJISDKManager.registerApp(with: self)
    }
    
    func initData(){
        self.userLocation = kCLLocationCoordinate2DInvalid
        self.droneLocation = kCLLocationCoordinate2DInvalid
        mapView.delegate = self
        mapView.mapType = .hybridFlyover
        mapView.showsUserLocation = true
        tapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(self.addWaypoints(_:)))
        self.mapView.addGestureRecognizer(self.tapGestureRecog!)
    }
    
    // MARK: UITapGestureRecognizer Methods
    @objc func addWaypoints(_ tapGesture:UITapGestureRecognizer) {
        
        let point = tapGestureRecog?.location(in: self.mapView)
        
        if tapGesture.state == UIGestureRecognizerState.ended {
            if self.isEditingPoints {
                self.mapController.addPoint(point: point!, withMapView: self.mapView)
            }
        }
    }
    
    // MARK: DJIAppActivationManagerDelegate Methods
    
    func manager(_ manager: DJIAppActivationManager!, didUpdate appActivationState: DJIAppActivationState) {
        self.activationState = appActivationState
        self.updateUI()
    }
    
    func manager(_ manager: DJIAppActivationManager!, didUpdate aircraftBindingState: DJIAppActivationAircraftBindingState) {
        self.aircraftBindingState = aircraftBindingState
        self.updateUI()
    }
    
    // DJISDKManagerDelegate Methods
    func appRegisteredWithError(_ error: Error?) {
        var message = ""
        if error != nil {
            print(error.debugDescription)
            message = "Register App Failed! Please enter your App Key in the plist file and check the network.";
        } else {
            print("RegisterAppSuccess")
            DJISDKManager.startConnectionToProduct()
            DJISDKManager.appActivationManager().delegate = self
            self.activationState = DJISDKManager.appActivationManager().appActivationState
            self.aircraftBindingState = DJISDKManager.appActivationManager().aircraftBindingState
            message = "Register app Successed!"
        }
        addLog(method: "appRegisteredWithError", message: message)
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        self.addLog(method: "productConnected", message: "Product_Connected")
        self.updateUI()
        if product != nil {
            let flightController = self.fetchFlightController()
            if flightController != nil {
                flightController?.delegate = self
                self.addLog(method: "productConnected_FC_Instanciated", message: "FC_Instanciated_OK")
            }else {
                self.addLog(method: "productConnected_FC_Instanciated", message: "FC_Instanciated_NIL")
            }
        }
        
    }
    
    func productDisconnected() {
        self.addLog(method: "productDisconnected", message: "Product_Disconnected")
        self.updateUI()
    }
    
    // MARK: CLLocation Methods
    
    func startUpdateLocation() {
        if CLLocationManager.locationServicesEnabled(){
            self.addLog(method: "startUpdateLocation", message: "update_location_enabled")
            if self.locationManager == nil {
               self.addLog(method: "startUpdateLocation_locationManager", message: "locationManager_initialized")
                self.locationManager = CLLocationManager()
                self.locationManager?.delegate = self
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager?.distanceFilter = 0.1
                self.locationManager?.requestAlwaysAuthorization()
                self.locationManager?.startUpdatingLocation()
            }else {
                self.addLog(method: "startUpdateLocation_locationManager", message:  "locationManager_initialized_failed")
            }
        }else {
               self.addLog(method: "startUpdateLocation", message:  "update_location_disabled")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.userLocation = location?.coordinate
    }
    
    // MARK : DJIFlightControllerDelegate Methods
    
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        self.addLog(method: "flightController", message: "FC_didupdateState")
        
        self.droneLocation = state.aircraftLocation?.coordinate
        
        let location = self.droneLocation ?? CLLocationCoordinate2DMake(0, 0)
        
        self.addLog(method: "flightController_droneLocation", message: "\(location.latitude) - \(location.longitude)")
        
        self.mapController.updateAircraftLocation(location: location, withMapView: self.mapView)
        
        let radianYaw = Float(self.getRadian(x: state.attitude.yaw))
        
        self.addLog(method: "flightController_droneLocation_yaw", message: "\(radianYaw)")
        self.mapController.updateAircraftHeading(heading: radianYaw)
    }
    func getDegree(x:Double) -> Double{
        return ((x) * 180.0 / Double.pi)
    }
    
    func getRadian(x:Double) -> Double {
        return ((x) * Double.pi / 180.0)
    }
    
    
    // MARK: MKMapViewDelegate Method
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKPointAnnotation.self) {
            self.addLog(method: "mapView_viewForAnnotation", message: "MKPointAnnotation")
            let pinView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "PinAnnotation")
            
            self.addLog(method: "mapView_viewForAnnotation_title", message: "waypoint")
            pinView.pinTintColor = UIColor.purple
            
            return pinView

        } else if annotation.isKind(of: DJIAircraftAnnotation.self){
            self.addLog(method: "mapView_viewForAnnotation", message: "DJIAircraftAnnotation")
            let annoView = DJIAircraftAnnotationView.init(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
            (annotation as! DJIAircraftAnnotation).annotationView = annoView
            return annoView
        }
        return nil
    }
    
    
    
    
    // MARK: Action Methods
    
    @IBAction func focusButtonPressed(_ sender: UIButton) {
        if self.droneLocation == nil {
            self.addLog(method: "focusButtonPressed", message: "Drone_Location_NIL")
        }else if CLLocationCoordinate2DIsValid(self.droneLocation!) {
            self.addLog(method: "focusButtonPressed", message: "Drone_Location_Valid")
            let span = MKCoordinateSpanMake(0.001, 0.001)
            let region = MKCoordinateRegion(center: self.droneLocation!, span: span)
            self.mapView.setRegion(region, animated: true)
        }else {
           self.addLog(method: "focusButtonPressed", message: "Drone_Location_Empty")
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        if (self.isEditingPoints) {
            self.mapController.cleanAllPointsWithMapView(mapView: self.mapView)
            self.editBtn .setTitle("Edit", for: UIControlState.normal)
            
        }else
        {
            self.editBtn.setTitle("Reset", for: UIControlState.normal)
        }
        
        self.isEditingPoints = !self.isEditingPoints;
    }
    
    // MARK: Auxiliar Methods
    
    func fetchFlightController() -> DJIFlightController?{
        
        if (DJISDKManager.product() == nil) {
            self.addLog(method: "fetchFlightController", message: "fetchFlightController_NIL")
            return nil
        }
        if (DJISDKManager.product()?.isKind(of: DJIAircraft.self))! {
            self.addLog(method: "fetchFlightController", message: "fetchFlightController_Aircraft_OK")
            return (DJISDKManager.product() as! DJIAircraft).flightController
        }
        return nil
    }
    
    func addLog(method:String,message:String) {
        FBManager.sharedInstance.log(method: method, withMessage: message)
    }
    
    func updateUI(){
        var bindState = ""
        var appState = ""
        switch self.aircraftBindingState {
        case DJIAppActivationAircraftBindingState.unboundButCannotSync:
            bindState = "Unbound. Please connect Internet to update state. ";
            break;
        case DJIAppActivationAircraftBindingState.unbound:
            bindState = "Unbound. Use DJI GO to bind the aircraft. ";
            break;
        case DJIAppActivationAircraftBindingState.unknown:
            bindState = "Unknown";
            break;
        case DJIAppActivationAircraftBindingState.bound:
            bindState = "Bound";
            break;
        case DJIAppActivationAircraftBindingState.initial:
            bindState = "Initial";
            break;
        case DJIAppActivationAircraftBindingState.notRequired:
            bindState = "Binding is not required. ";
            break;
        case DJIAppActivationAircraftBindingState.notSupported:
            bindState = "App Activation is not supported. ";
            break;
        }
        
        switch self.activationState {
        case DJIAppActivationState.loginRequired:
            appState = "Login is required to activate.";
            break;
        case DJIAppActivationState.unknown:
            appState = "AppUnknown";
            break;
        case DJIAppActivationState.activated:
            appState = "Activated";
            break;
        case DJIAppActivationState.notSupported:
            appState = "App Activation is not supported.";
            break;
        }
        
        addLog(method: "updateUI_bindState", message: bindState)
        addLog(method: "updateUI_appState", message: appState)
    }
    
    
}
