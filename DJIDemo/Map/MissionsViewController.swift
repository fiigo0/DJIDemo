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

class MissionsViewController: UIViewController, DJISDKManagerDelegate, DJIAppActivationManagerDelegate, MKMapViewDelegate,CLLocationManagerDelegate,DJIFlightControllerDelegate, DJIWaypointConfigViewDelegate {
    
    
    enum DJIGSViewMode {
        case DJIGSViewMode_ViewMode
        case DJIGSViewMode_EditMode
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    //Status bar
    @IBOutlet var statusView: UIView!
    @IBOutlet weak var gpsLbl: UILabel!
    @IBOutlet weak var modeLbl: UILabel!
    @IBOutlet weak var hsLbl: UILabel!
    @IBOutlet weak var vsLbl: UILabel!
    @IBOutlet weak var altLbl: UILabel!
    
    //Main Menu
    @IBOutlet var mainMenuView: UIView!
    @IBOutlet weak var focusButton: UIButton!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    //Waypoint Button Menu
    @IBOutlet var waypointsMenuView: UIView!
    @IBOutlet weak var backMenuButton: UIButton!
    @IBOutlet weak var addMenuButton: UIButton!
    @IBOutlet weak var clearMenuButton: UIButton!
    @IBOutlet weak var stopMenuButton: UIButton!
    @IBOutlet weak var startMenuButton: UIButton!
    @IBOutlet weak var configMenuButton: UIButton!
    
    //Mission Config View Menu
    @IBOutlet var waypoingConfigView: DJIWaypointConfigView!
    
    var waypointsMission:DJIMutableWaypointMission?
    
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
    var isSettingMap:Bool = false;
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //Delivery Order
    var deliveryOrder:Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.registerApp()
        self.initData()
        self.updateUI()
        self.focusMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startUpdateLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager?.stopUpdatingLocation()
        FBManager.sharedInstance.resetLogs()
    }
    
    func registerApp(){
        DJISDKManager.registerApp(with: self)
    }
    
    
    func initUI() {
        self.modeLbl.text = "N/A"
        self.gpsLbl.text = "0"
        self.vsLbl.text = "0.0 M/S"
        self.hsLbl.text = "0.0 M/S"
        self.altLbl.text = "0 M"
        
        //Status bar
        statusView.frame = CGRect(x: 0, y: Double(self.view.frame.height - 40), width: Double(self.view.frame.width), height: 40.0)
        self.view.addSubview(statusView)
        self.statusView.isHidden = true
        
        //Main Menu
        mainMenuView.frame = CGRect(x: Double(self.view.frame.width - 150), y: 40, width: 100, height: Double(self.view.frame.height))
        self.view.addSubview(mainMenuView)
        
        //Missions Menu
        waypointsMenuView.frame = CGRect(x: Double(self.view.frame.width - 150), y: 40, width: 100, height: Double(self.view.frame.height - 40))
        self.view.addSubview(waypointsMenuView)
        self.waypointsMenuView.isHidden = true
        
        //waypoint VC
        waypoingConfigView.frame = CGRect(x: 130, y: 0, width: 553, height: 320)
        waypoingConfigView.center = self.view.center
        waypoingConfigView.delegate = self
        waypoingConfigView.initUI()
        self.view.addSubview(waypoingConfigView)
        self.waypoingConfigView.isHidden = true
        
    }
    
    func initData(){
        self.userLocation = kCLLocationCoordinate2DInvalid
        self.droneLocation = kCLLocationCoordinate2DInvalid
        mapView.delegate = self
        mapView.mapType = .hybridFlyover
        mapView.showsUserLocation = true
        tapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(self.addWaypoints(_:)))
        self.mapView.addGestureRecognizer(self.tapGestureRecog!)
        
//        let deliveryLocation:CLLocation = deliveryOrder.coordinate
//        //Need at least 2 to start the mission
//        self.mapController.addDeliveryLocation(location: deliveryLocation, withMapView: self.mapView)
//        let second = CLLocation(latitude: 25.670012, longitude: -101.377818)
//        self.mapController.addDeliveryLocation(location: second, withMapView: self.mapView)
        
    }
    
    // MARK: UITapGestureRecognizer Methods
    @objc func addWaypoints(_ tapGesture:UITapGestureRecognizer) {
        
        let point = tapGestureRecog?.location(in: self.mapView)
        
        if tapGesture.state == UIGestureRecognizerState.ended {
            if self.isEditingPoints {
                self.mapController.addPoint(point: point!, withMapView: self.mapView)
            }else if self.isSettingMap{
                self.mapController.addMapCoordinate(point: point!, withMapView: self.mapView)
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
        self.focusMap()
        if product != nil {
            let flightController = self.fetchFlightController()
            if flightController != nil {
                flightController?.delegate = self
                self.addLog(method: "productConnected_FC_Instanciated", message: "FC_Instanciated_OK")
                FBManager.sharedInstance.updateDroneConnectionStatus(status: "Connected");
            }else {
                self.addLog(method: "productConnected_FC_Instanciated", message: "FC_Instanciated_NIL")
            }
        }
        
    }
    
    func productDisconnected() {
        self.addLog(method: "productDisconnected", message: "Product_Disconnected")
        FBManager.sharedInstance.updateDroneConnectionStatus(status: "Disconnected");
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
        self.droneLocation = state.aircraftLocation?.coordinate
        let location = self.droneLocation ?? CLLocationCoordinate2DMake(0, 0)
        self.addLog(method: "flightController_droneLocation", message: "\(location.latitude),\(location.longitude)")
//        FBManager.sharedInstance.updateDroneLocation(location:  "\(location.latitude),\(location.longitude)")
        self.mapController.updateAircraftLocation(location: location, withMapView: self.mapView)
        let radianYaw = Float(self.getRadian(x: state.attitude.yaw))
        
        self.modeLbl.text = "\(state.flightMode)"
        self.gpsLbl.text = "\(state.satelliteCount)"
        self.vsLbl.text = NSString(format: "%0.1f M/S", state.velocityZ) as String
        self.hsLbl.text = NSString(format: "%0.1f M/S", sqrtf((state.velocityX * state.velocityX) + (state.velocityY * state.velocityY))) as String
        self.altLbl.text = NSString(format: "%0.1f M", state.altitude) as String
        self.mapController.updateAircraftHeading(heading: radianYaw)
        let locationString =  "\(location.latitude),\(location.longitude)"
        FBManager.sharedInstance.updateDroneLocation(currentAltitude: self.altLbl.text! , velocity: self.vsLbl.text!, location: locationString)
        
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
            let pinView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "PinAnnotation")
            pinView.pinTintColor = UIColor.green
            return pinView
            
        } else if annotation.isKind(of: DJIAircraftAnnotation.self){            
            let annoView = DJIAircraftAnnotationView.init(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
            (annotation as! DJIAircraftAnnotation).annotationView = annoView
            return annoView
        }
        return nil
    }
    
    
    
    
    // MARK: Action Methods
    
    @IBAction func focusButtonPressed(_ sender: UIButton) {
        self.focusMap()
    }
    
    func focusMap(){
        if self.droneLocation == nil {
            self.addLog(method: "focusButtonPressed", message: "Drone_Location_NIL")
        }else if CLLocationCoordinate2DIsValid(self.droneLocation!) {
            self.addLog(method: "focusButtonPressed", message: "Drone_Location_Valid")
            let span = MKCoordinateSpanMake(0.001, 0.001)
            let region = MKCoordinateRegion(center: self.droneLocation!, span: span)
            self.mapView.setRegion(region, animated: true)
        }else if CLLocationCoordinate2DIsValid(self.userLocation!){
            self.addLog(method: "focusButtonPressed", message: "Using_User_Location_Valid")
            let span = MKCoordinateSpanMake(0.001, 0.001)
            let region = MKCoordinateRegion(center: self.userLocation!, span: span)
            self.mapView.setRegion(region, animated: true)
        }else {
            self.addLog(method: "focusButtonPressed", message: "Drone_Location_Empty")
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        self.mainMenuView.isHidden = true
        self.waypointsMenuView.isHidden = false
    }
    
    @IBAction func showStatusButtonPressed(_ sender: UIButton) {
        
        self.statusView.isHidden = !self.statusView.isHidden
        if self.statusView.isHidden {
            self.statusButton.backgroundColor = UIColor.gray
        }else {
            self.statusButton.backgroundColor = UIColor.blue
        }
    }
    
    // MARK: Waypoint Menu Actions
    
    func missionOperator() -> (DJIWaypointMissionOperator?){
        return DJISDKManager.missionControl()?.waypointMissionOperator()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.mainMenuView.isHidden = false
        self.waypointsMenuView.isHidden = true
    }
    
    @IBAction func addWaypointButtonPressed(_ sender: UIButton) {
        if self.isEditingPoints {
            self.isEditingPoints = false
            self.addMenuButton.setTitle("Add", for: .normal)
        } else {
            self.isEditingPoints = true
            self.addMenuButton.setTitle("Finished", for: .normal)
        }
    }
    @IBAction func clearWaypointsButtonPressed(_ sender: UIButton) {
        self.mapController.cleanAllPointsWithMapView(mapView: self.mapView)
        FBManager.sharedInstance.clearWaypoints();
    }
    
    @IBAction func configMissionButtonPressed(_ sender: UIButton) {
        print("Config")
        self.waypoingConfigView.isHidden = false
        
        self.initMissionController()
     
    }
    
    
    @IBAction func startMissionButtonPressed(_ sender: UIButton) {
        self.missionOperator()?.startMission(completion: { (error) in
            if error != nil {
                self.addLog(method: "startMissionButtonPressed", message: "Start mission failed \(error.debugDescription)")
            } else {
                self.addLog(method: "startMissionButtonPressed", message: "Mission Started")
            }
        })
    }
    
    @IBAction func stopMissionButtonPressed(_ sender: UIButton) {
        if self.isSettingMap {
            self.isSettingMap = false
            self.stopMenuButton.setTitle("Set Map", for: .normal)
        } else {
            self.isSettingMap = true
            self.stopMenuButton.setTitle("Ok", for: .normal)
        }
        
    }
    
    func switchMode(mode:DJIGSViewMode){
        if mode == DJIGSViewMode.DJIGSViewMode_EditMode{
            self.focusMap()
        }
    }
    
    // MARK: DJIWaypointConfigViewDelegate
    
    func cancelBtnActionInDJIWaypointConfigViewController(waypointConfigVC: DJIWaypointConfigView) {
        UIView.animate(withDuration: 0.25) {
            self.waypoingConfigView.isHidden = true
        }
    }
    
    func finishBtnActionInDJIWaypointConfigViewController(waypointConfigVC: DJIWaypointConfigView) {
        UIView.animate(withDuration: 0.25) {
            self.waypoingConfigView.isHidden = true
            
        }
        
        
        for index in 0...((self.waypointsMission?.waypointCount)! - 1)  {
            let waypoint = self.waypointsMission?.waypoint(at: index)
            let altitude : Float = NSString(string: (self.waypoingConfigView.altitudeTextField?.text)!).floatValue
            waypoint?.altitude = altitude
        }
        
        self.waypointsMission?.maxFlightSpeed = NSString(string: (self.waypoingConfigView.maxFlightSpeedTextField?.text)!).floatValue
        self.waypointsMission?.autoFlightSpeed = NSString(string: (self.waypoingConfigView.autoFlightSpeedTextField?.text)!).floatValue
        
        let selectedMode: Int = (self.waypoingConfigView.headingSegmentControl?.selectedSegmentIndex)!
        let modeNumber = UInt(selectedMode)
        let mode : DJIWaypointMissionHeadingMode = DJIWaypointMissionHeadingMode(rawValue: modeNumber)!
        self.waypointsMission?.headingMode = mode
        
        //Update DroneData Node
        FBManager.sharedInstance.updateDroneData(node: "max_altitude", value: (self.waypoingConfigView.altitudeTextField?.text)!);
        
        let selectedActionMode: Int = (self.waypoingConfigView.actionSegmentedControl?.selectedSegmentIndex)!
        let actionModeNumber = UInt8(selectedActionMode)
        let actionMode : DJIWaypointMissionFinishedAction = DJIWaypointMissionFinishedAction(rawValue:actionModeNumber)!
        self.waypointsMission?.finishedAction = actionMode
        
        self.missionOperator()?.load(self.waypointsMission!)
        
        self.missionOperator()?.removeAllListeners()
        
        self.missionOperator()?.addListener(toFinished: self, with: DispatchQueue.main, andBlock: { (error:Error?) in
            if error != nil {
                self.addLog(method: "finishBtnActionInDJIWaypointConfigViewController", message: "Mission Execution Failed : \(error.debugDescription)")
            }else {
                self.addLog(method: "finishBtnActionInDJIWaypointConfigViewController", message: "Mission Execution Finished")
            }
        })
        
        self.missionOperator()?.uploadMission(completion: { (error) in
            if error != nil {
                self.addLog(method: "finishBtnActionInDJIWaypointConfigViewController_uploadMission", message: "Upload Mission failed : \(error.debugDescription)")
            } else {
                self.addLog(method: "finishBtnActionInDJIWaypointConfigViewController_uploadMission", message: "Upload Mission Finished")
            }
        })
        
    }
    
    func initMissionController(){
        let wayPoints = self.mapController.wayPoints
        // TODO: veryfy nil waypoints
        
        if wayPoints.count < 2 {
            print("No or not enought waypoints for missions")
            return
        }
        
        if (self.waypointsMission != nil) {
            self.addLog(method: "initMissionController", message: "waypointsMission_Not_NIL")
            self.waypointsMission?.removeAllWaypoints()
        } else {
            self.waypointsMission = DJIMutableWaypointMission()
            self.addLog(method: "initMissionController", message: "waypointsMission_NIL")
        }
        
        for waypoint in wayPoints {
            if CLLocationCoordinate2DIsValid(waypoint.coordinate){
                let waypoint = DJIWaypoint(coordinate: waypoint.coordinate)
                self.waypointsMission?.add(waypoint)
                self.addLog(method: "initMissionController_waypoints", message: "waypointsMission_waypoints_\(String(describing: self.waypointsMission?.waypointCount))")
            }
        }
    }
    
    func setDefaultWaymissionSettings(){
        
        self.initMissionController()
        
        for index in 0...((self.waypointsMission?.waypointCount)! - 1)  {
            let waypoint = self.waypointsMission?.waypoint(at: index)
            waypoint?.altitude = 100
        }
        
        self.waypointsMission?.maxFlightSpeed = 10
        self.waypointsMission?.autoFlightSpeed = 8
        self.waypointsMission?.headingMode = .auto
        self.waypointsMission?.finishedAction = .goHome
        self.missionOperator()?.load(self.waypointsMission!)
        
        self.missionOperator()?.removeAllListeners()
        
        self.missionOperator()?.addListener(toFinished: self, with: DispatchQueue.main, andBlock: { (error:Error?) in
            if error != nil {
                self.addLog(method: "setDefaultWaymissionSettings", message: "Mission Execution Failed : \(error.debugDescription)")
            }else {
                self.addLog(method: "setDefaultWaymissionSettings", message: "Mission Execution Finished")
            }
        })
        
        self.missionOperator()?.uploadMission(completion: { (error) in
            if error != nil {
                self.addLog(method: "setDefaultWaymissionSettings", message: "Upload Mission failed : \(error.debugDescription)")
            } else {
                self.addLog(method: "setDefaultWaymissionSettings", message: "Upload Mission Finished")
            }
        })
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
        FBManager.sharedInstance.log(method: method, withMessage: " ")
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
