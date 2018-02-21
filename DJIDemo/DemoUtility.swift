//
//  DemoUtility.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 2/21/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import UIKit
import DJISDK

class DemoUtility: NSObject {

    weak var WeakRef :DemoUtility? = DemoUtility()
    
    func fetchFlightController() -> DJIFlightController?{
        if (DJISDKManager.product() == nil) {
            return nil
        }
        if (DJISDKManager.product()?.isKind(of: DJIAircraft.self))! {
            return (DJISDKManager.product() as! DJIAircraft).flightController
        }
        return nil
    }
    
    func voidShowMessage(title:String, message:String,target:UIViewController, cancelBtnTitle:String){
        
        //TODO: verify correct implementarion of this method
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                // create the alert
                let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                target.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    func getDegree(x:Double) -> Double{
        return ((x) * 180.0 / Double.pi)
    }
    
    func getRadian(x:Double) -> Double {
        return ((x) * Double.pi / 180.0)
    }
}
