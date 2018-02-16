//
//  ViewController.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 2/16/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit
import DJISDK

class ViewController: UIViewController, DJISDKManagerDelegate,DJIAppActivationManagerDelegate {

    @IBOutlet weak var bindingStateLabel: UILabel!
    @IBOutlet weak var appActivationLabel: UILabel!
    var activationState:DJIAppActivationState!
    var aircraftBindingState:DJIAppActivationAircraftBindingState!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerApp()
        self.updateUI()
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
    
    func updateUI(){
        switch self.aircraftBindingState! {
        case DJIAppActivationAircraftBindingState.unboundButCannotSync:
            self.bindingStateLabel.text = "Unbound. Please connect Internet to update state. ";
            break;
        case DJIAppActivationAircraftBindingState.unbound:
            self.bindingStateLabel.text = "Unbound. Use DJI GO to bind the aircraft. ";
            break;
        case DJIAppActivationAircraftBindingState.unknown:
            self.bindingStateLabel.text = "Unknown";
            break;
        case DJIAppActivationAircraftBindingState.bound:
            self.bindingStateLabel.text = "Bound";
            break;
        case DJIAppActivationAircraftBindingState.initial:
            self.bindingStateLabel.text = "Initial";
            break;
        case DJIAppActivationAircraftBindingState.notRequired:
            self.bindingStateLabel.text = "Binding is not required. ";
            break;
        case DJIAppActivationAircraftBindingState.notSupported:
            self.bindingStateLabel.text = "App Activation is not supported. ";
            break;
        }
        
        switch self.activationState! {
        case DJIAppActivationState.loginRequired:
            self.appActivationLabel.text = "Login is required to activate.";
            break;
        case DJIAppActivationState.unknown:
            self.appActivationLabel.text = "Unknown";
            break;
        case DJIAppActivationState.activated:
            self.appActivationLabel.text = "Activated";
            break;
        case DJIAppActivationState.notSupported:
            self.appActivationLabel.text = "App Activation is not supported.";
            break;
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
    
    // MARK: Button's Action
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: false) { (userAccountState:DJIUserAccountState, error:Error?) in
            if error != nil {
                print("Login error \(error.debugDescription)")
            } else {
                print("login success")
            }
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        DJISDKManager.userAccountManager().logOutOfDJIUserAccount { (error:Error?) in
            if error != nil {
                print("Logout error \(error.debugDescription)")
            } else {
                print("logout success")
            }
        }
        
    }
    
    
}

