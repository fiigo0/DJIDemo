//
//  ViewController.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 2/16/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit
import DJISDK

class ViewController: UIViewController, DJISDKManagerDelegate,DJIAppActivationManagerDelegate,DJIVideoFeedListener, DJICameraDelegate {

    @IBOutlet weak var bindingStateLabel: UILabel!
    @IBOutlet weak var appActivationLabel: UILabel!
    var activationState:DJIAppActivationState!
    var aircraftBindingState:DJIAppActivationAircraftBindingState!
    
    @IBOutlet weak var fpvView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerApp()
        self.updateUI()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let camera = self.fetchCamera()
        if((camera != nil) && (camera?.delegate?.isEqual(self))!){
            camera?.delegate = nil
        }
        self.resetVideoPreview()
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
    
    func setupVideoPreviewer() {
        
        VideoPreviewer.instance().setView(self.fpvView)
        let product = DJISDKManager.product();
        
        //Use "SecondaryVideoFeed" if the DJI Product is A3, N3, Matrice 600, or Matrice 600 Pro, otherwise, use "primaryVideoFeed".
        if ((product?.model == DJIAircraftModelNameA3)
            || (product?.model == DJIAircraftModelNameN3)
            || (product?.model == DJIAircraftModelNameMatrice600)
            || (product?.model == DJIAircraftModelNameMatrice600Pro)){
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.add(self, with: nil)
        }else{
            DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        }
        VideoPreviewer.instance().start()
    }
    
    func resetVideoPreview() {
        VideoPreviewer.instance().unSetView()
        let product = DJISDKManager.product();
        
        //Use "SecondaryVideoFeed" if the DJI Product is A3, N3, Matrice 600, or Matrice 600 Pro, otherwise, use "primaryVideoFeed".
        if ((product?.model == DJIAircraftModelNameA3)
            || (product?.model == DJIAircraftModelNameN3)
            || (product?.model == DJIAircraftModelNameMatrice600)
            || (product?.model == DJIAircraftModelNameMatrice600Pro)){
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.remove(self)
        }else{
            DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
        }
    }
    
    func fetchCamera() -> DJICamera? {
        let product = DJISDKManager.product()
        
        if (product == nil) {
            return nil
        }
        
        if (product!.isKind(of: DJIAircraft.self)) {
            return (product as! DJIAircraft).camera
        } else if (product!.isKind(of: DJIHandheld.self)) {
            return (product as! DJIHandheld).camera
        }
        return nil
    }
    
    func showAlertViewWithTitle(title: String, withMessage message: String) {
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title:"OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // DJISDKManagerDelegate Methods
    func productConnected(_ product: DJIBaseProduct?) {
        
        NSLog("Product Connected")
        
        if (product != nil) {
            let camera = self.fetchCamera()
            if (camera != nil) {
                camera!.delegate = self
            }
            self.setupVideoPreviewer()
        }
        
        //If this demo is used in China, it's required to login to your DJI account to activate the application. Also you need to use DJI Go app to bind the aircraft to your DJI account. For more details, please check this demo's tutorial.
        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: false) { (state, error) in
            if(error != nil){
                NSLog("Login failed: %@" + String(describing: error))
            }
        }
        
    }
    
    func productDisconnected() {
        
        NSLog("Product Disconnected")
        
        let camera = self.fetchCamera()
        if((camera != nil) && (camera?.delegate?.isEqual(self))!){
            camera?.delegate = nil
        }
        self.resetVideoPreview()
    }
    
    // DJICameraDelegate Method
    func camera(_ camera: DJICamera, didUpdate cameraState: DJICameraSystemState) {
        print(cameraState.mode)
    }
    
    // DJIVideoFeedListener Method
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData rawData: Data) {
        
        let videoData = rawData as NSData
        let videoBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.length)
        videoData.getBytes(videoBuffer, length:videoData.length)
        VideoPreviewer.instance().push(videoBuffer, length: Int32(videoData.length))
        
    }
    
    
}

