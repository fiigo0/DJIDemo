//
//  WaypointViewController.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 2/16/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit
import DJISDK

class WaypointViewController: UIViewController, DJISDKManagerDelegate, DJIAppActivationManagerDelegate, MKMapViewDelegate,CLLocationManagerDelegate, DJIFlightControllerDelegate, DJIBaseProductDelegate {

    //Objects
    var mapController:DJIMapController?
    
    //Location
    var locationManager:CLLocationManager?
    var userLocation:CLLocationCoordinate2D?
    var droneLocation:CLLocationCoordinate2D?
    
    //Properties
    var activationState:DJIAppActivationState!
    var aircraftBindingState:DJIAppActivationAircraftBindingState!
    var editPoints:[CLLocation] = [];
    var tapGestureRecog:UITapGestureRecognizer?
    var isEditingPoints:Bool = false
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //UI Elements
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var modeLbl: UILabel!
    @IBOutlet weak var gpsLbl: UILabel!
    @IBOutlet weak var hsLbl: UILabel!
    @IBOutlet weak var vsLbl: UILabel!
    @IBOutlet weak var altitudeLbl: UILabel!
    @IBOutlet weak var errorLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerApp()
        self.initUI()
        self.initData()
        self.addLog(message: "1 Did load")
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

 
    
    func initUI() {
        self.modeLbl.text = "N/A";
        self.gpsLbl.text = "0";
        self.vsLbl.text = "0.0 M/S";
        self.hsLbl.text = "0.0 M/S";
        self.altitudeLbl.text = "0 M";
    }
    
    func initData() {
        self.userLocation = kCLLocationCoordinate2DInvalid
        self.droneLocation = kCLLocationCoordinate2DInvalid
        self.mapController = DJIMapController()
        mapView.delegate = self
        mapView?.showsUserLocation = true
        
        tapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(self.addWaypoints(_:)))
//        tapGestureRecog?.numberOfTapsRequired = 1
//        tapGestureRecog?.numberOfTouchesRequired = 1
        self.mapView.addGestureRecognizer(self.tapGestureRecog!)
        
    }
    
    func registerApp(){
        DJISDKManager.registerApp(with: self)
    }
    
    // MARK: DJISDKManagerDelegate Methods
    func appRegisteredWithError(_ error: Error?) {
        var message = "2 Register app Successed!"
        
        if error != nil {
            print(error.debugDescription)
            message = "2 Register App Failed! Please enter your App Key in the plist file and check the network."
        } else {
            print("RegisterAppSuccess")
            
            DJISDKManager.startConnectionToProduct()
            DJISDKManager.appActivationManager().delegate = self
            self.activationState = DJISDKManager.appActivationManager().appActivationState
            self.aircraftBindingState = DJISDKManager.appActivationManager().aircraftBindingState
            self.addLog(message: "\(DJISDKManager.appActivationManager().aircraftBindingState)")
        }
        self.addLog(message: message)
        print(message)
    }
    
    
    
    func productConnected(_ product: DJIBaseProduct?) {
        if product != nil {
            self.addLog(message: "Product Connected")
            let flightController = DemoUtility().fetchFlightController()
            if (flightController != nil) {
                flightController?.delegate = self
            } else {
                self.addLog(message: "Error on FC")
            }
        } else {
            self.addLog(message: "product not connected")
        }
    }
    
    func productDisconnected() {
        print("Product Disconnected")
    }
    
    // MARK: CLLocation Methods
    
    func startUpdateLocation() {
        self.addLog(message: "start update location")
        if CLLocationManager.locationServicesEnabled(){
            self.addLog(message: "update location enabled")
            if self.locationManager == nil {
                self.addLog(message: "location manager not nil")
                self.locationManager = CLLocationManager()
                self.locationManager?.delegate = self
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager?.distanceFilter = 0.1
                self.locationManager?.requestAlwaysAuthorization()
                self.locationManager?.startUpdatingLocation()
            }else {
                self.addLog(message: "location services are not enabled")
            }
        }
        
        
    }
    
    
    // MARK: UITapGestureRecognizer Methods
    @objc func addWaypoints(_ tapGesture:UITapGestureRecognizer) {
        
        let point = tapGestureRecog?.location(in: self.mapView)
        
        if tapGesture.state == UIGestureRecognizerState.ended {
            if self.isEditingPoints {
                self.mapController?.addPoint(point: point!, withMapView: self.mapView)
            }
        }
    }
    
    // MARK: MKMapViewDelegate Method
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKPointAnnotation.self) {
            let pinView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "PinAnnotation")
            pinView.pinTintColor = UIColor.purple
            return pinView
        } else if annotation.isKind(of: DJIAircraftAnnotation.self){
            self.addLog(message: "AirCraft annotation detected")
            let annoView = DJIAircraftAnnotationView.init(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
            (annotation as! DJIAircraftAnnotation).annotationView = annoView
            return annoView
        }
        return nil
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
    
   
    
    func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
            
        case .denied, .restricted:
            print("location access denied")
            errorLbl.text = "location access denied"
            
        default:
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func editButton(_ sender: UIButton) {
        if (self.isEditingPoints) {
            self.mapController?.cleanAllPointsWithMapView(mapView: self.mapView)
            self.editBtn .setTitle("Edit", for: UIControlState.normal)
            
        }else
        {
            self.editBtn.setTitle("Reset", for: UIControlState.normal)
        }
        
        self.isEditingPoints = !self.isEditingPoints;
    }
    
    @IBAction func focusMapAction(_ sender: UIButton) {
        if self.droneLocation == nil {
            errorLbl.text = "drone location = nil"
            self.addLog(message: "drone location nil")
        }else if CLLocationCoordinate2DIsValid(self.droneLocation!) {
            self.addLog(message: "drone location valid")
            let span = MKCoordinateSpanMake(0.001, 0.001)
            let region = MKCoordinateRegion(center: self.droneLocation!, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.userLocation = location?.coordinate
    }
    
    
    // MARK : DJIFlightControllerDelegate Methods
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        self.addLog(message: "FC did update state ")
        self.droneLocation = state.aircraftLocation?.coordinate
        self.modeLbl.text = state.flightModeString
        self.gpsLbl.text = "\(state.satelliteCount)"
        self.vsLbl.text = "\(state.velocityZ) M/S"
        self.hsLbl.text = "\(sqrtf(state.velocityX * state.velocityX + state.velocityZ * state.velocityY)) M/S"
        self.altitudeLbl.text = "\(state.altitude) M"
        self.mapController?.updateAircraftLocation(location: self.droneLocation!, withMapView: self.mapView)
        
        errorLbl.text = "FC delegate updated"
        
        //TODO: is the weak reference well implemented?
        
        let radianYaw = Float((DemoUtility().getRadian(x: state.attitude.yaw)))
        self.mapController?.updateAircraftHeading(heading: radianYaw)
        
    }
    
    
    func displayMessage(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
 
    func addLog(message:String) {
        FBManager.sharedInstance.addLog(message: message)
    }
    
    func updateUI(){
        var bindState = ""
        var appState = ""
        switch self.aircraftBindingState! {
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
        
        switch self.activationState! {
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
        
        addLog(message: appState)
        addLog(message: bindState)
    }
    
}
