//
//  MissionsViewController.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 2/21/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit
import DJISDK

class MissionsViewController: UIViewController, DJISDKManagerDelegate, DJIAppActivationManagerDelegate {

    var activationState:DJIAppActivationState = DJIAppActivationState.unknown
    var aircraftBindingState:DJIAppActivationAircraftBindingState = DJIAppActivationAircraftBindingState.unknown
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerApp()
        self.updateUI()        
    }
    
    func registerApp(){
        DJISDKManager.registerApp(with: self)
    }
    
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
            self.updateUI()
            message = "Register app Successed!"
        }
        addLog(method: "appRegisteredWithError", message: message)
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
    func productConnected(_ product: DJIBaseProduct?) {
        self.addLog(method: "productConnected", message: "Product_Connected")
        self.updateUI()
    }
    
    func productDisconnected() {
        self.addLog(method: "productDisconnected", message: "Product_Disconnected")
        self.updateUI()
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
